require 'rails_helper'

RSpec.describe 'Cocktails', type: :request do
  describe 'GET /cocktails' do
    it 'returns 200 with a data array' do
      get '/cocktails'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('data')
      expect(body['data']).to be_an(Array)
    end

    it 'does not include meta when there is no pagination' do
      get '/cocktails'
      body = JSON.parse(response.body)
      expect(body).not_to have_key('meta')
    end

    # ai/v1-redesign-plan.md's creator/submitter attribution workstream,
    # B3: resolving each cocktail's registered creator must stay a single
    # preloaded batch query, not one query per cocktail — proven by
    # counting SQL queries against a database with several distinct
    # creators, not just asserted from reading the includes() call.
    #
    # Scoped to queries against the "users" table specifically: a
    # separate, pre-existing N+1 on `image_attachment: :blob` (one
    # `active_storage_attachments` query per cocktail regardless of
    # whether an image is attached — confirmed via a live query trace,
    # present before this PR's changes, unrelated to creator/submitter
    # attribution) would otherwise swamp this measurement. That one is
    # out of scope here — flagged separately, not fixed in this PR.
    it 'resolves registered creators across the collection with a "users" query count independent of N' do
      submitter = create(:user)
      category = create(:category)

      count_user_queries_for = lambda do
        query_count = 0
        counter = lambda do |_name, _started, _finished, _id, payload|
          next if payload[:name] == 'SCHEMA' || payload[:cached]

          query_count += 1 if payload[:sql].include?('FROM "users"')
        end
        ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { get '/cocktails' }
        query_count
      end

      create(:cocktail, :published, submitted_by: submitter, creator_user: create(:user), category:)
      baseline_count = count_user_queries_for.call

      create_list(:user, 8).each do |creator|
        create(:cocktail, :published, submitted_by: submitter, creator_user: creator, category:)
      end
      scaled_up_count = count_user_queries_for.call

      data = JSON.parse(response.body)['data']
      expect(data.count { |c| c['creator'].present? }).to be >= 9
      # The real N+1 proof: going from 1 cocktail-with-creator to 9 must
      # not multiply the "users" query count — a per-cocktail creator
      # lookup would scale with N; a single preloaded batch query does
      # not (submitted_by and creator_user each contribute at most one
      # query regardless of how many distinct users are involved).
      expect(scaled_up_count).to eq(baseline_count)
    end
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18). Explicit scope, not a default_scope (see
  # Cocktail.published) — applied here at the controller level.
  describe 'GET /cocktails visibility' do
    let(:editor) { create(:user, :editor) }

    it 'excludes drafts for an anonymous request' do
      draft = create(:cocktail)
      published = create(:cocktail, :published, creator_unknown: true)

      get '/cocktails'
      ids = JSON.parse(response.body)['data'].pluck('id')
      expect(ids).to include(published.id)
      expect(ids).not_to include(draft.id)
    end

    it 'excludes drafts for an authenticated non-editor' do
      draft = create(:cocktail)
      get '/cocktails', headers: auth_headers_for(create(:user))
      ids = JSON.parse(response.body)['data'].pluck('id')
      expect(ids).not_to include(draft.id)
    end

    it 'includes drafts for an authenticated editor' do
      draft = create(:cocktail)
      get '/cocktails', headers: auth_headers_for(editor)
      ids = JSON.parse(response.body)['data'].pluck('id')
      expect(ids).to include(draft.id)
    end

    it 'sets Cache-Control: private, no-store when an editor views the index' do
      get '/cocktails', headers: auth_headers_for(editor)
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    it 'does not set a private Cache-Control for an anonymous request' do
      get '/cocktails'
      expect(response.headers['Cache-Control']).not_to eq('private, no-store')
    end
  end

  describe 'GET /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:cocktail) { create(:cocktail, :published, submitted_by: owner, creator_unknown: true) }

    it 'returns 200 with a data object' do
      get "/cocktails/#{cocktail.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('data')
    end

    # ai/v1-redesign-plan.md's publication-lifecycle workstream
    # (2026-11-18) — 404, never 403: a non-editor must not be able to
    # distinguish "doesn't exist" from "exists but is a draft."
    it 'returns 404 for a draft requested by an anonymous user' do
      draft = create(:cocktail)
      get "/cocktails/#{draft.id}"
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['errors'][0]['code']).to eq('not_found')
    end

    it 'returns 404 for a draft requested by an authenticated non-editor' do
      draft = create(:cocktail)
      get "/cocktails/#{draft.id}", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 200 for a draft requested by an authenticated editor' do
      draft = create(:cocktail)
      get "/cocktails/#{draft.id}", headers: auth_headers_for(create(:user, :editor))
      expect(response).to have_http_status(:ok)
    end

    it 'sets Cache-Control: private, no-store on the 404 denial for a draft' do
      draft = create(:cocktail)
      get "/cocktails/#{draft.id}"
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    # Round-5 review check: a genuinely nonexistent cocktail and a
    # concealed draft must produce indistinguishable responses to a
    # non-editor — same status, same JSON envelope, same caching
    # header. Before CocktailLookup#find_cocktail rescued
    # ActiveRecord::RecordNotFound, a nonexistent id raised unhandled
    # instead of reaching this envelope at all (confirmed live, not
    # assumed) — a real, visible difference this test now guards
    # against regressing.
    it 'is indistinguishable from a nonexistent cocktail for an anonymous requester' do
      draft = create(:cocktail)
      get "/cocktails/#{draft.id}"
      draft_status = response.status
      draft_body = JSON.parse(response.body)
      draft_cache_control = response.headers['Cache-Control']

      get '/cocktails/999999999'
      expect(response.status).to eq(draft_status)
      expect(JSON.parse(response.body)).to eq(draft_body)
      expect(response.headers['Cache-Control']).to eq(draft_cache_control)
    end

    # Exposed for deterministic client-side ranking (e.g. Home's featured-
    # cocktail tie-break: likes_count desc, then created_at desc, then id) —
    # previously only likes_count/id were available, with no way to order by
    # recency at all.
    it 'includes created_at' do
      get "/cocktails/#{cocktail.id}"
      body = JSON.parse(response.body)
      expect(body['data']['created_at']).to be_present
    end

    # ai/v1-redesign-plan.md's creator/submitter attribution workstream,
    # B3's "additive-then-remove" API transition strategy: the legacy
    # bartender/bartender_id keys must keep returning exactly what they
    # always have (now backed by the renamed submitted_by association),
    # while the new keys appear alongside them — never a bare rename in
    # one deploy.
    it 'exposes both the legacy bartender keys and the new submitted_by/creator keys with matching values' do
      get "/cocktails/#{cocktail.id}"
      data = JSON.parse(response.body)['data']
      expect(data['bartender_id']).to eq(owner.id)
      expect(data['bartender']['id']).to eq(owner.id)
      expect(data['submitted_by_id']).to eq(owner.id)
      expect(data['submitted_by']['id']).to eq(owner.id)
      expect(data).to have_key('creator_user_id')
      expect(data).to have_key('creator_name')
      # true, not the old default false — this describe block's shared
      # cocktail is now :published with creator_unknown explicitly set
      # (publication requires an explicit attribution decision; see
      # Cocktail#creator_attribution_required_while_published).
      expect(data['creator_unknown']).to eq(true)
    end

    it 'resolves a registered creator to a nested object with name/avatar/location fields' do
      creator = create(:user, full_name: 'Dale DeGroff', location: 'New York, NY')
      cocktail_with_creator = create(:cocktail, :published, submitted_by: owner, creator_user: creator)

      get "/cocktails/#{cocktail_with_creator.id}"
      data = JSON.parse(response.body)['data']
      expect(data['creator']['id']).to eq(creator.id)
      expect(data['creator']['full_name']).to eq('Dale DeGroff')
      expect(data['creator']['location']).to eq('New York, NY')
      expect(data['creator']).to have_key('avatar')
    end

    # Confirms BartenderSerializer (shared by bartender/submitted_by/
    # creator) exposes exactly the intended public identity fields —
    # nothing sensitive (password_digest, the bartender boolean flag,
    # etc.) ever leaks through, since AMS `attributes` is an explicit
    # whitelist, not reflection over the model's columns.
    it 'exposes only the intended public identity fields on every registered-person object' do
      creator = create(:user)
      cocktail_with_creator = create(:cocktail, :published, submitted_by: owner, creator_user: creator)

      get "/cocktails/#{cocktail_with_creator.id}"
      data = JSON.parse(response.body)['data']
      expected_keys = %w[id full_name username location avatar]
      expect(data['creator'].keys).to match_array(expected_keys)
      expect(data['bartender'].keys).to match_array(expected_keys)
      expect(data['submitted_by'].keys).to match_array(expected_keys)
    end

    it 'returns a null creator when no registered creator is linked' do
      get "/cocktails/#{cocktail.id}"
      data = JSON.parse(response.body)['data']
      expect(data['creator']).to be_nil
    end
  end

  describe 'POST /cocktails' do
    let(:user) { create(:user, :editor) }
    let(:category) { create(:category) }
    let(:valid_params) do
      { cocktail: { name: 'Old Fashioned', description: 'A classic', execution: 'Stir well',
                    ingredients: 'whiskey,bitters,sugar', category_id: category.id } }
    end

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        post '/cocktails', params: valid_params
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    # ai/v1-redesign-plan.md's editorial-authorization workstream
    # (2026-11-18): Kinpour's catalog is editor-managed, not
    # self-service — an ordinary authenticated user (including a
    # bartender) has no path to create a cocktail at all.
    context 'when authenticated but not an editor' do
      it 'returns 403 with editorial_authorization_required error' do
        post '/cocktails', params: valid_params, headers: auth_headers_for(create(:user))
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('editorial_authorization_required')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    context 'when authenticated as an editor' do
      it 'creates a cocktail and returns 201 with data' do
        post '/cocktails', params: valid_params, headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
        expect(Cocktail.last.submitted_by_id).to eq(user.id)
      end

      it 'ignores a spoofed user_id param' do
        other_user = create(:user)
        post '/cocktails', params: valid_params.deep_merge(cocktail: { user_id: other_user.id }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.submitted_by_id).to eq(user.id)
      end

      # ai/v1-redesign-plan.md's editorial-authorization workstream
      # (2026-11-18): submitted_by_id must always be the authenticated
      # editor who made the request, never a client-supplied value —
      # an editor entering another bartender's recipe doesn't transfer
      # the record's ownership to that bartender, it stays owned by the
      # editor who actually submitted it.
      it 'ignores a spoofed submitted_by_id param — the submitter is always the authenticated editor' do
        other_user = create(:user)
        post '/cocktails', params: valid_params.deep_merge(cocktail: { submitted_by_id: other_user.id }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.submitted_by_id).to eq(user.id)
      end

      it 'accepts an explicit creator_name distinct from the submitter' do
        post '/cocktails', params: valid_params.deep_merge(cocktail: { creator_name: 'Dale DeGroff' }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.creator_name).to eq('Dale DeGroff')
        expect(Cocktail.last.creator_user_id).to be_nil
      end

      it 'accepts an explicit creator_unknown flag' do
        post '/cocktails', params: valid_params.deep_merge(cocktail: { creator_unknown: true }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.creator_unknown).to be(true)
      end

      it 'rejects conflicting creator attribution with a 422' do
        creator = create(:user)
        post '/cocktails',
             params: valid_params.deep_merge(cocktail: { creator_user_id: creator.id, creator_name: 'Dale DeGroff' }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /cocktails/:id' do
    let(:original_submitter) { create(:user) }
    let(:editor) { create(:user, :editor) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, submitted_by: original_submitter) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as an editor' do
      it 'updates the cocktail and returns 200 with data' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated Name' } },
                                           headers: auth_headers_for(editor)
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
      end

      # ai/v1-redesign-plan.md's editorial-authorization workstream
      # (2026-11-18): editing a cocktail never transfers it — the
      # original submitter stays the original submitter even when an
      # editor (who may not be that submitter at all) makes the edit.
      it 'ignores a submitted_by_id param — the original submitter never changes' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { submitted_by_id: editor.id } },
                                           headers: auth_headers_for(editor)
        expect(response).to have_http_status(:ok)
        expect(cocktail.reload.submitted_by_id).to eq(original_submitter.id)
      end

      it 'independently updates creator attribution while leaving submitted_by_id untouched' do
        creator = create(:user)
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { creator_user_id: creator.id, submitted_by_id: editor.id } },
              headers: auth_headers_for(editor)
        expect(response).to have_http_status(:ok)
        cocktail.reload
        expect(cocktail.creator_user_id).to eq(creator.id)
        expect(cocktail.submitted_by_id).to eq(original_submitter.id)
      end
    end

    # The original submitter is no longer special — ai/v1-redesign-plan.md's
    # editorial-authorization workstream (2026-11-18) replaces the old
    # owner-based model entirely. No non-editor, including the cocktail's
    # own original submitter, may edit it.
    context 'when authenticated as the original submitter, who is not an editor' do
      it 'returns 403 with editorial_authorization_required error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Hacked' } },
                                           headers: auth_headers_for(original_submitter)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('editorial_authorization_required')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    context 'when authenticated as an unrelated non-editor' do
      it 'returns 403 with editorial_authorization_required error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Hacked' } },
                                           headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('editorial_authorization_required')
      end
    end

    # Direct proof that creator attribution (B2) grants no authorization:
    # being credited as a cocktail's *creator* must not let that user
    # edit the record unless they are also separately an editor.
    context 'when authenticated as the credited creator but not an editor' do
      it 'returns 403 with editorial_authorization_required error' do
        creator = create(:user)
        cocktail_with_creator = create(:cocktail, submitted_by: original_submitter, creator_user: creator)

        patch "/cocktails/#{cocktail_with_creator.id}", params: { cocktail: { name: 'Hacked' } },
                                                        headers: auth_headers_for(creator)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'photo upload validation' do
    let(:user) { create(:user, :editor) }
    let(:category) { create(:category) }
    let(:base_params) do
      { cocktail: { name: 'Sunset Spritz', description: 'Refreshing', execution: 'Shake',
                    ingredients: 'gin,tonic', category_id: category.id } }
    end

    context 'on POST /cocktails' do
      it 'rejects a non-image file with upload_invalid_type error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: invalid_type_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
        expect(body['errors'][0]['message']).to be_present
      end

      it 'rejects a GIF with upload_invalid_type error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: gif_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
      end

      it 'rejects an oversized file with upload_too_large error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: oversized_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_too_large')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    context 'on PATCH /cocktails/:id' do
      let(:cocktail) { create(:cocktail, submitted_by: user) }

      it 'rejects a non-image file with upload_invalid_type error' do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: invalid_type_upload } },
              headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
      end

      it 'rejects an oversized file with upload_too_large error' do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: oversized_upload } },
              headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_too_large')
      end
    end
  end

  describe 'background variant processing' do
    let(:user) { create(:user, :editor) }
    let(:category) { create(:category) }
    let(:base_params) do
      { cocktail: { name: 'Paloma', description: 'Bright and citrusy', execution: 'Build over ice',
                    ingredients: 'tequila,grapefruit soda', category_id: category.id } }
    end

    it 'enqueues ProcessImageVariantJob when a valid photo is uploaded on create' do
      expect do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: valid_image_upload }),
             headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:created)
    end

    it 'does not enqueue ProcessImageVariantJob when no photo is uploaded on create' do
      expect do
        post '/cocktails', params: base_params, headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when an invalid photo is rejected' do
      expect do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: invalid_type_upload }),
             headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'enqueues ProcessImageVariantJob when a valid photo is uploaded on update' do
      cocktail = create(:cocktail, submitted_by: user)

      expect do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: valid_image_upload } },
              headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /cocktails/:id' do
    let(:original_submitter) { create(:user) }
    let(:editor) { create(:user, :editor) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, submitted_by: original_submitter) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        delete "/cocktails/#{cocktail.id}"
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as an editor' do
      it 'destroys the cocktail with no content' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(editor)
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when authenticated as the original submitter, who is not an editor' do
      it 'returns 403 with editorial_authorization_required error' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(original_submitter)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('editorial_authorization_required')
      end
    end

    context 'when authenticated as an unrelated non-editor' do
      it 'returns 403 with editorial_authorization_required error' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('editorial_authorization_required')
      end
    end

    context 'when authenticated as the credited creator but not an editor' do
      it 'returns 403 with editorial_authorization_required error' do
        creator = create(:user)
        cocktail_with_creator = create(:cocktail, submitted_by: original_submitter, creator_user: creator)

        delete "/cocktails/#{cocktail_with_creator.id}", headers: auth_headers_for(creator)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18). These are the only two places published_at is ever
  # written — never accepted as an ordinary update param.
  describe 'POST /cocktails/:id/publish' do
    let(:editor) { create(:user, :editor) }

    it 'returns 401 when unauthenticated' do
      cocktail = create(:cocktail, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/publish"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a non-editor' do
      cocktail = create(:cocktail, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/publish", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:forbidden)
    end

    it 'publishes a complete, attributed draft and sets published_at' do
      cocktail = create(:cocktail, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/publish", headers: auth_headers_for(editor)
      expect(response).to have_http_status(:ok)
      expect(cocktail.reload.published_at).to be_present
    end

    it "doesn't bump published_at on a repeat publish call (idempotent)" do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      original_timestamp = cocktail.published_at

      post "/cocktails/#{cocktail.id}/publish", headers: auth_headers_for(editor)
      expect(cocktail.reload.published_at).to be_within(1.second).of(original_timestamp)
    end

    it 'rejects publishing without creator attribution with a 422' do
      cocktail = create(:cocktail)
      post "/cocktails/#{cocktail.id}/publish", headers: auth_headers_for(editor)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(cocktail.reload.published_at).to be_nil
    end

    it 'rejects publishing an incomplete recipe with a 422' do
      cocktail = create(:cocktail, creator_unknown: true, name: nil)
      post "/cocktails/#{cocktail.id}/publish", headers: auth_headers_for(editor)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /cocktails/:id/unpublish' do
    let(:editor) { create(:user, :editor) }

    it 'returns 401 when unauthenticated' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/unpublish"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a non-editor' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/unpublish", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:forbidden)
    end

    it 'unpublishes a published cocktail, clearing published_at' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      post "/cocktails/#{cocktail.id}/unpublish", headers: auth_headers_for(editor)
      expect(response).to have_http_status(:ok)
      expect(cocktail.reload.published_at).to be_nil
    end
  end

  describe 'published_at is never an ordinary update param' do
    it 'ignores a published_at value sent on PATCH /cocktails/:id' do
      editor = create(:user, :editor)
      cocktail = create(:cocktail)

      patch "/cocktails/#{cocktail.id}", params: { cocktail: { published_at: Time.current.iso8601 } },
                                         headers: auth_headers_for(editor)
      expect(response).to have_http_status(:ok)
      expect(cocktail.reload.published_at).to be_nil
    end
  end
end

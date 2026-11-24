require 'rails_helper'

RSpec.describe 'Images legacy endpoints', type: :request do
  describe 'PATCH /image/:id' do
    it 'raises RoutingError — route removed' do
      expect { patch '/image/1' }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'PATCH /avatar/:id' do
    it 'raises RoutingError — route removed' do
      expect { patch '/avatar/1' }.to raise_error(ActionController::RoutingError)
    end
  end
end

# ai/v1-redesign-plan.md's publication-lifecycle workstream (2026-11-18)
# — the gated image-delivery redesign. config.active_storage.draw_routes
# is false (config/application.rb); these two controllers' four routes
# are the only HTTP surfaces that can ever produce a link to an
# attachment's actual bytes.
RSpec.describe 'Gated image delivery', type: :request do
  include ActiveJob::TestHelper

  # A real, decodable JPEG — `valid_image_upload`'s fake byte string is
  # fine for upload-validation specs (which never actually process the
  # bytes) but not for these, which exercise real variant processing
  # (.processed calls libvips/ImageMagick on the attached bytes).
  def attach_real_image(record)
    record.image.attach(
      io: Rails.public_path.join('photos/cocktails/Airmail.jpg').open,
      filename: 'Airmail.jpg',
      content_type: 'image/jpeg'
    )
    record.save!
  end

  # Same real JPEG as attach_real_image, but as an uploaded-file param —
  # needed wherever a test exercises real variant *processing* (e.g.
  # ProcessImageVariantJob actually running), since valid_image_upload's
  # fake byte string isn't decodable by libvips/ImageMagick.
  def real_image_upload
    Rack::Test::UploadedFile.new(Rails.public_path.join('photos/cocktails/Airmail.jpg'), 'image/jpeg')
  end

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — a "public creator" per User.followable: has at
  # least one published cocktail crediting them, so their avatar stays
  # anonymously fetchable under Users::AvatarsController's new
  # require_avatar_visible check.
  def published_creator
    creator = create(:user)
    create(:cocktail, :published, submitted_by: creator, creator_unknown: true, category: create(:category))
    creator
  end

  describe 'GET /cocktails/:id/image (variant)' do
    it 'serves the variant for a published cocktail, publicly' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('image/webp')
      expect(response.body.bytesize).to be > 0
    end

    it 'returns 404 for a draft requested by an anonymous user' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for a draft requested by an authenticated non-editor' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:not_found)
    end

    it "serves a draft's variant for an authenticated editor" do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image", headers: auth_headers_for(create(:user, :editor))
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when no image is attached' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      get "/cocktails/#{cocktail.id}/image"
      expect(response).to have_http_status(:not_found)
    end

    it 'sets Cache-Control: private, no-store on a successful response' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image"
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    it 'sets Cache-Control: private, no-store on a denied response' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image"
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    # The real authorization-before-processing proof: a denied request
    # must never trigger variant processing as a side effect.
    it 'does not process the variant when the request is denied' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image"
      expect(response).to have_http_status(:not_found)
      variant = cocktail.send(:image_variant, cocktail.image)
      expect(variant.processed?).to be(false)
    end
  end

  describe 'GET /cocktails/:id/image/original' do
    it 'serves the original, unprocessed bytes for a published cocktail' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image/original"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('image/jpeg')
      expect(response.body.bytesize).to eq(cocktail.image.blob.byte_size)
    end

    it 'returns 404 for a draft requested anonymously' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image/original"
      expect(response).to have_http_status(:not_found)
    end
  end

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — avatars are no longer unconditionally public.
  # Confirmed live before this fix: a plain account with no public
  # presence had its avatar fully fetchable by sequential id guessing,
  # anonymously. require_avatar_visible (Users::AvatarsController) is
  # the narrowest fix: public creators stay anonymously reachable (the
  # legitimate, unchanged use — cocktail cards' BartenderSerializer
  # avatar); everyone else requires self/editor/an incoming follow.
  describe 'GET /users/:id/avatar (variant) authorization' do
    it 'serves a public creator’s variant anonymously, same as before this change' do
      creator = published_creator
      attach_real_image(creator)

      get "/users/#{creator.id}/avatar"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('image/webp')
    end

    it 'returns 404 when no avatar is attached, for a public creator (still reachable, nothing to serve)' do
      creator = published_creator
      get "/users/#{creator.id}/avatar"
      expect(response).to have_http_status(:not_found)
    end

    it 'sets Cache-Control: private, no-store on a successful response' do
      creator = published_creator
      attach_real_image(creator)

      get "/users/#{creator.id}/avatar"
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    it 'returns 404 for a private account’s avatar requested anonymously' do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for a private account’s avatar requested by an unrelated authenticated user' do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:not_found)
    end

    it 'sets Cache-Control: private, no-store on a denied response too' do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar"
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end

    it "serves a private account's own avatar to themselves" do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar", headers: auth_headers_for(private_account)
      expect(response).to have_http_status(:ok)
    end

    it "serves a private account's avatar to an authenticated editor" do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar", headers: auth_headers_for(create(:user, :editor))
      expect(response).to have_http_status(:ok)
    end

    it 'serves a private account’s avatar to someone that account follows (the incoming-follow rule)' do
      private_account = create(:user)
      attach_real_image(private_account)
      viewer = create(:user)
      create(:follow, follower: private_account, followee: viewer)

      get "/users/#{private_account.id}/avatar", headers: auth_headers_for(viewer)
      expect(response).to have_http_status(:ok)
    end

    it 'does not grant visibility merely because current_user follows the target (one-directional rule)' do
      private_account = create(:user)
      attach_real_image(private_account)
      viewer = create(:user)
      create(:follow, follower: viewer, followee: private_account)

      get "/users/#{private_account.id}/avatar", headers: auth_headers_for(viewer)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for a nonexistent user id, identical to a private account’s denial' do
      get '/users/999999/avatar'
      expect(response).to have_http_status(:not_found)
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end
  end

  describe 'GET /users/:id/avatar/original authorization' do
    it 'serves a public creator’s original, unprocessed bytes anonymously' do
      creator = published_creator
      attach_real_image(creator)

      get "/users/#{creator.id}/avatar/original"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('image/jpeg')
    end

    it 'returns 404 for a private account’s original avatar requested anonymously' do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar/original"
      expect(response).to have_http_status(:not_found)
    end

    it "serves a private account's own original avatar to themselves" do
      private_account = create(:user)
      attach_real_image(private_account)

      get "/users/#{private_account.id}/avatar/original", headers: auth_headers_for(private_account)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Disk delivery (test env)' do
    it 'streams the bytes directly rather than redirecting' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image/original"
      expect(response).to have_http_status(:ok)
      expect(response.headers['Location']).to be_nil
    end
  end

  describe 'non-Disk (S3-style) delivery' do
    it 'redirects to a short-lived presigned URL instead of streaming' do
      # Neither aws-sdk-s3 (require: false in the Gemfile) nor
      # ActiveStorage::Service::S3Service itself (lib/active_storage/
      # service/s3_service.rb — outside Zeitwerk's app/ autoload path,
      # only required when the amazon service is actually configured)
      # is loaded in test env, whose configured service is Disk.
      # Explicit requires so the constant exists for instance_double to
      # verify against.
      require 'aws-sdk-s3'
      require 'active_storage/service/s3_service'

      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      fake_service = instance_double(ActiveStorage::Service::S3Service)
      allow(fake_service).to receive(:url).and_return('https://s3.example.com/fake-signed-url')
      # any_instance_of, scoped to this one example: ActiveStorage::Blob
      # has no per-request seam to inject a service double through
      # normal association loading, and this is the standard way to
      # test the S3-vs-Disk branch without a real S3 call in test env.
      allow_any_instance_of(ActiveStorage::Blob).to receive(:service).and_return(fake_service)

      get "/cocktails/#{cocktail.id}/image/original"

      expect(response).to redirect_to('https://s3.example.com/fake-signed-url')
      expect(fake_service).to have_received(:url).with(
        anything, hash_including(expires_in: 5.minutes, disposition: 'inline')
      )
    end

    # Round-5 check: the original-blob redirect above doesn't exercise
    # the processed-variant path at all — ActiveStorage.track_variants
    # is true in this app (see ImageDelivery's own comment), so the
    # processed image is an ActiveStorage::VariantWithRecord, not a
    # Blob, and VariantWithRecord#url/#service both delegate elsewhere
    # (to .image and .blob respectively) — worth its own proof, not
    # assumed to behave the same way just because the code path is
    # shared.
    it 'redirects the processed VariantWithRecord too, short-lived, with the denial-grade caching header' do
      require 'aws-sdk-s3'
      require 'active_storage/service/s3_service'

      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      # Process the variant for real first, against the real Disk
      # service — this creates the ActiveStorage::VariantRecord so
      # #processed is a no-op lookup by the time the stub is in place,
      # avoiding the need to also stub .upload/.exist? for a fake
      # service that was never meant to handle real processing.
      cocktail.send(:image_variant, cocktail.image).processed
      expect(cocktail.send(:image_variant, cocktail.image)).to be_a(ActiveStorage::VariantWithRecord)

      fake_service = instance_double(ActiveStorage::Service::S3Service)
      allow(fake_service).to receive(:url).and_return('https://s3.example.com/fake-variant-url')
      allow_any_instance_of(ActiveStorage::Blob).to receive(:service).and_return(fake_service)

      get "/cocktails/#{cocktail.id}/image"

      expect(response).to redirect_to('https://s3.example.com/fake-variant-url')
      expect(fake_service).to have_received(:url).with(
        anything, hash_including(expires_in: 5.minutes, disposition: 'inline')
      )
      expect(response.headers['Cache-Control']).to eq('private, no-store')
    end
  end

  describe 'old Active Storage engine routes are gone' do
    it 'no longer routes /rails/active_storage/blobs/*' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)
      signed_id = cocktail.image.blob.signed_id

      expect do
        get "/rails/active_storage/blobs/redirect/#{signed_id}/Airmail.jpg"
      end.to raise_error(ActionController::RoutingError)
    end

    it 'no longer routes /rails/active_storage/representations/*' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      expect do
        get '/rails/active_storage/representations/redirect/some-signed-id/Airmail.jpg'
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'upload → replace → delete, end to end through the new delivery path' do
    it 'serves the replaced image, not the original, after an update' do
      editor = create(:user, :editor)
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      get "/cocktails/#{cocktail.id}/image/original"
      original_bytes = response.body

      patch "/cocktails/#{cocktail.id}",
            params: { cocktail: { photo: valid_image_upload } },
            headers: auth_headers_for(editor)
      expect(response).to have_http_status(:ok)

      get "/cocktails/#{cocktail.id}/image/original"
      expect(response.body).not_to eq(original_bytes)
    end

    it '404s the image endpoint after the attachment itself is purged' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      attach_real_image(cocktail)

      cocktail.image.purge

      get "/cocktails/#{cocktail.id}/image"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'ProcessImageVariantJob' do
    it 'still completes successfully and produces a servable variant' do
      editor = create(:user, :editor)
      category = create(:category)

      perform_enqueued_jobs do
        post '/cocktails',
             params: { cocktail: { name: 'Paloma', description: 'Bright', execution: 'Build over ice',
                                   ingredients: 'tequila,grapefruit soda', category_id: category.id,
                                   creator_unknown: true, photo: real_image_upload } },
             headers: auth_headers_for(editor)
      end
      expect(response).to have_http_status(:created)

      cocktail = Cocktail.last
      variant = cocktail.send(:image_variant, cocktail.image)
      expect(variant.processed?).to be(true)
    end
  end
end

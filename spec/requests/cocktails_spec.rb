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
  end

  describe 'GET /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:cocktail) { create(:cocktail, bartender: owner) }

    it 'returns 200 with a data object' do
      get "/cocktails/#{cocktail.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('data')
    end
  end

  describe 'POST /cocktails' do
    let(:user) { create(:user) }
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

    context 'when authenticated' do
      it 'creates a cocktail and returns 201 with data' do
        post '/cocktails', params: valid_params, headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
        expect(Cocktail.last.bartender_id).to eq(user.id)
      end

      it 'ignores a spoofed user_id param' do
        other_user = create(:user)
        post '/cocktails', params: valid_params.deep_merge(cocktail: { user_id: other_user.id }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.bartender_id).to eq(user.id)
      end
    end
  end

  describe 'PATCH /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, bartender: owner) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as the owner' do
      it 'updates the cocktail and returns 200 with data' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated Name' } },
                                           headers: auth_headers_for(owner)
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403 with forbidden error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Hacked' } },
                                           headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('forbidden')
        expect(body['errors'][0]['message']).to be_present
      end
    end
  end

  describe 'photo upload validation' do
    let(:user) { create(:user) }
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
      let(:cocktail) { create(:cocktail, bartender: user) }

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
    let(:user) { create(:user) }
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
      cocktail = create(:cocktail, bartender: user)

      expect do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: valid_image_upload } },
              headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, bartender: owner) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        delete "/cocktails/#{cocktail.id}"
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the cocktail with no content' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403 with forbidden error' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('forbidden')
      end
    end
  end
end

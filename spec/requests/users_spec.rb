require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'PATCH /me avatar upload validation' do
    let(:user) { create(:user) }

    it 'rejects a non-image content type with 422 and errors key' do
      patch '/me',
            params: { user: { avatar: invalid_type_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'rejects a GIF with 422' do
      patch '/me',
            params: { user: { avatar: gif_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects an oversized file with 422 and errors key' do
      patch '/me',
            params: { user: { avatar: oversized_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'accepts a valid image and returns 200' do
      patch '/me',
            params: { user: { avatar: valid_image_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /me background variant processing' do
    let(:user) { create(:user) }

    it 'enqueues ProcessImageVariantJob when a valid avatar is uploaded' do
      expect do
        patch '/me',
              params: { user: { avatar: valid_image_upload } },
              headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when no avatar is uploaded' do
      expect do
        patch '/me',
              params: { user: { full_name: 'New Name' } },
              headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when an invalid avatar is rejected' do
      expect do
        patch '/me',
              params: { user: { avatar: invalid_type_upload } },
              headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end
  end
end

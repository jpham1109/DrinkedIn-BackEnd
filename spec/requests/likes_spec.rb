require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  describe 'POST /likes' do
    let(:user) { create(:user) }
    let(:cocktail) { create(:cocktail) }

    context 'when unauthenticated' do
      it 'returns 401' do
        post '/likes', params: { liked_cocktail_id: cocktail.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a like as current_user' do
        post '/likes', params: { liked_cocktail_id: cocktail.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Like.last.liker_id).to eq(user.id)
      end

      it 'ignores a spoofed liker_id param' do
        other_user = create(:user)
        post '/likes', params: { liker_id: other_user.id, liked_cocktail_id: cocktail.id },
                       headers: auth_headers_for(user)
        expect(Like.last.liker_id).to eq(user.id)
      end
    end
  end

  describe 'DELETE /likes/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail) }
    let(:like) { create(:like, liker: owner, liked_cocktail: cocktail) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/likes/#{like.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the like' do
        delete "/likes/#{like.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        delete "/likes/#{like.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

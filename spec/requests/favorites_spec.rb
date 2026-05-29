require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  describe 'GET /favorites' do
    context 'when unauthenticated' do
      it 'returns 401' do
        get '/favorites'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'returns only the current user favorites' do
        user = create(:user)
        other_user = create(:user)
        create(:favorite, user: user)
        create(:favorite, user: other_user)

        get '/favorites', headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |f| f['user_id'] }
        expect(ids).to all(eq(user.id))
      end
    end
  end

  describe 'POST /favorites' do
    let(:user) { create(:user) }
    let(:bar) { create(:bar) }

    context 'when unauthenticated' do
      it 'returns 401' do
        post '/favorites', params: { favorited_bar_id: bar.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a favorite as current_user' do
        post '/favorites', params: { favorited_bar_id: bar.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Favorite.last.user_id).to eq(user.id)
      end
    end
  end

  describe 'DELETE /favorites/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:favorite) { create(:favorite, user: owner) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/favorites/#{favorite.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the favorite' do
        delete "/favorites/#{favorite.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        delete "/favorites/#{favorite.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

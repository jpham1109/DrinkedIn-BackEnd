require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  describe 'POST /follows' do
    let(:user) { create(:user) }
    let(:target) { create(:user) }

    context 'when unauthenticated' do
      it 'returns 401' do
        post '/follows', params: { followee_id: target.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a follow as current_user' do
        post '/follows', params: { followee_id: target.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Follow.last.follower_id).to eq(user.id)
      end

      it 'ignores a spoofed follower_id param' do
        other_user = create(:user)
        post '/follows', params: { follower_id: other_user.id, followee_id: target.id },
                         headers: auth_headers_for(user)
        expect(Follow.last.follower_id).to eq(user.id)
      end
    end
  end

  describe 'DELETE /follows/:id' do
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }
    let(:other_user) { create(:user) }
    let(:follow) { create(:follow, follower:, followee:) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/follows/#{follow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the follower (unfollow)' do
      it 'destroys the follow' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(follower)
        expect(response).to have_http_status(:no_content)
        expect(Follow.exists?(follow.id)).to be false
      end
    end

    context 'when authenticated as the followee (remove follower)' do
      it 'destroys the follow' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(followee)
        expect(response).to have_http_status(:no_content)
        expect(Follow.exists?(follow.id)).to be false
      end
    end

    context 'when authenticated as an unrelated user' do
      it 'returns 403 and leaves the follow intact' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        expect(Follow.exists?(follow.id)).to be true
      end
    end
  end
end

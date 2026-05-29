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
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:follow) { create(:follow, follower: owner) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/follows/#{follow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the follow' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

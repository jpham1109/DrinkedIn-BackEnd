require 'rails_helper'

RSpec.describe 'Cocktails', type: :request do
  describe 'GET /cocktails' do
    it 'returns a successful response' do
      get '/cocktails'
      expect(response).to have_http_status(:ok)
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
      it 'returns 401' do
        post '/cocktails', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a cocktail owned by current_user' do
        post '/cocktails', params: valid_params, headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
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
      it 'returns 401' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'updates the cocktail' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated Name' } },
                                           headers: auth_headers_for(owner)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Hacked' } },
                                           headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, bartender: owner) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/cocktails/#{cocktail.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the cocktail' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

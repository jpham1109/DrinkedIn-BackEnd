require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  describe 'GET /categories' do
    it 'rebuilds a relative popular_drinks image path into a fully-qualified URL' do
      create(:category, popular_drinks: [{ name: 'Old Fashioned', image: 'photos/cocktails/old-fashioned.jpg' }])

      get '/categories'

      image = json_response.first['popular_drinks'].first['image']
      expect(image).to eq('http://test.host/photos/cocktails/old-fashioned.jpg')
    end

    it 'rehosts a legacy absolute URL without double-prefixing' do
      create(:category,
             popular_drinks: [{ name: 'Old Fashioned', image: 'http://localhost:3000/photos/cocktails/old-fashioned.jpg' }])

      get '/categories'

      image = json_response.first['popular_drinks'].first['image']
      expect(image).to eq('http://test.host/photos/cocktails/old-fashioned.jpg')
      expect(image).not_to include('localhost:3000')
    end

    it 'returns nil for a blank image without raising' do
      create(:category, popular_drinks: [{ name: 'Mystery Drink', image: nil }])

      get '/categories'

      expect(response).to have_http_status(:ok)
      expect(json_response.first['popular_drinks'].first['image']).to be_nil
    end

    it 'returns nil for an unparseable image value without raising' do
      create(:category, popular_drinks: [{ name: 'Mystery Drink', image: "http://[::not-a-valid-host" }])

      get '/categories'

      expect(response).to have_http_status(:ok)
      expect(json_response.first['popular_drinks'].first['image']).to be_nil
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end

require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  describe 'GET /categories' do
    # Replaces the four URL-rebuilding specs that used to live here —
    # they tested CategorySerializer's absolute_image_url/extract_path
    # logic, which existed only to serve the now-removed `popular_drinks`
    # field (ai/v1-redesign-plan.md's category audit, 2026-11-18).
    # Category previews are dynamic now, sourced from real cocktail
    # records on the frontend (CategoryCard.jsx) — nothing server-side
    # computes a preview image anymore.
    it 'no longer exposes popular_drinks' do
      create(:category)

      get '/categories'

      expect(response).to have_http_status(:ok)
      expect(json_response.first).not_to have_key('popular_drinks')
    end

    it 'still exposes id, name, and definition' do
      create(:category, name: 'Tiki', definition: 'A tropical tradition.')

      get '/categories'

      data = json_response.find { |c| c['name'] == 'Tiki' }
      expect(data['id']).to be_present
      expect(data['definition']).to eq('A tropical tradition.')
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end

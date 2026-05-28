require 'rails_helper'

RSpec.describe 'GET /cocktails', type: :request do
  it 'returns a successful response' do
    get '/cocktails'
    expect(response).to have_http_status(:ok)
  end
end

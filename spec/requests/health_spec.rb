require 'rails_helper'

RSpec.describe 'Health', type: :request do
  describe 'GET /up' do
    it 'returns 200 when the database is reachable' do
      get '/up'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['status']).to eq('ok')
    end

    it 'returns 503 when the database is unreachable' do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError, 'connection refused')
      get '/up'
      expect(response).to have_http_status(:service_unavailable)
    end

    it 'requires no authentication' do
      get '/up'
      expect(response).not_to have_http_status(:unauthorized)
    end
  end
end

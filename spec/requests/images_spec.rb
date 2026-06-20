require 'rails_helper'

RSpec.describe 'Images legacy endpoints', type: :request do
  describe 'PATCH /image/:id' do
    it 'raises RoutingError — route removed' do
      expect { patch '/image/1' }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'PATCH /avatar/:id' do
    it 'raises RoutingError — route removed' do
      expect { patch '/avatar/1' }.to raise_error(ActionController::RoutingError)
    end
  end
end

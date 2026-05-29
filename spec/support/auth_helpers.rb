module AuthHelpers
  def auth_headers_for(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.jwt_key, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

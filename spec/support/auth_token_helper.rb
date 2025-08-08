require "jwt"

module AuthTokenHelper
  def decode_jwt(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })
    decoded[0].with_indifferent_access
  end
end

RSpec.configure do |config|
  config.include AuthTokenHelper
end

require "jwt"
module AuthTokenHelper
  def generate_auth_token(user, expiration = 7.days.from_now)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: expiration.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  def decode_auth_token(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })
    decoded[0].with_indifferent_access
  rescue JWT::ExpiredSignature
    nil
  end
end

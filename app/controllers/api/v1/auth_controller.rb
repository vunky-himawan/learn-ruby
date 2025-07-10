class Api::V1::AuthController < ApplicationController
  include Respondable, ActionController::Cookies, TokenHelper

  def register
    user_params = Auth::UserRegistrationRequest.new(params.permit(:email, :password, :role_id).to_h)

    user = Auth::UserRegistrationService.new(
      email: user_params.email,
      password: user_params.password,
      role_id: user_params.role_id.to_i
    ).call

    created(user, "User created successfully")
  end

  def login
    user_params = Auth::UserLoginRequest.new(params.permit(:email, :password, :client_id).to_h)

    unless user_params.valid?
      return unprocessable_entity("Validation failed", user_params.errors.full_messages)
    end

    credentials = Auth::UserLoginService.new(
      email: user_params.email,
      password: user_params.password,
      client_id: user_params.client_id,
      cookies: cookies
    ).call

    success({
      access_token: credentials.token,
      expires_in: credentials.expires_in
    }, "Login successful")
  end

  def me
    token_string = request.headers["Authorization"]&.split(" ")&.last

    result = Auth::GetCurrentUserService.new(token_string: token_string).call

    success(result, "User retrieved successfully")
  end

  def refresh_token
    new_token = Auth::RefreshTokenService.new(
      cookies: cookies
    ).call

    success({
      access_token: new_token.token,
      expires_in: new_token.expires_in
    }, "Access token refreshed successfully")
  end

  def logout
    Auth::UserLogoutService.new(cookies: cookies).call

    success(nil, "Logged out successfully")
  end
end

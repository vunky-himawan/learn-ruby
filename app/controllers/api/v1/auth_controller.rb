class Api::V1::AuthController < ApplicationController
  include Respondable, ActionController::Cookies

  def register
    begin
      user_params = Auth::UserRegistrationRequest.new(params.permit(:email, :password, :role_id).to_h)

      user = Auth::UserRegistrationService.new(
        email: user_params.email,
        password: user_params.password,
        role_id: user_params.role_id.to_i
      ).call

      if user
        created(user, "User created successfully")
      else
        unprocessable_entity("Validation failed", user.errors.full_messages)
      end
    rescue ActiveRecord::RecordInvalid => e
      unprocessable_entity("Validation failed", e.record.errors.full_messages)
    rescue ActiveRecord::RecordNotFound => e
      not_found("Resource not found", [ e.message ])
    rescue StandardError => e
      puts "Parameters: #{params.inspect}"
      puts e.message
      internal_server_error("An unexpected error occurred", [ e.message ])
    end
  end

  def login
    client_id = params[:client_id]

    user_params = params.permit(:email, :password)

    user = User.find_by(email: user_params[:email])

    return bad_request("Invalid credentials", "Email or password is incorrect") unless user

    return bad_request("Invalid credentials", "Email or password is incorrect") unless user.authenticate(user_params[:password])

    client_app = Doorkeeper::Application.find_by(uid: client_id)

    return bad_request("Invalid client ID", "Client ID is incorrect") unless client_app

    credentials = Doorkeeper::AccessToken.create!(
      application_id: client_app.id,
      resource_owner_id: user.id,
      expires_in: 2.hours,
      scopes: "public",
      use_refresh_token: true
    )

    set_refresh_token(credentials.refresh_token)

    success({
      access_token: credentials.token,
      expires_in: credentials.expires_in
    }, "Login successful")
  rescue StandardError => e
    internal_server_error("An unexpected error occurred", [ e.message ])
  end

  def me
    begin
      token_string = request.headers["Authorization"]&.split(" ")&.last

      return unauthorized("Please provide a valid access token") unless token_string

      access_token = Doorkeeper::AccessToken.by_token(token_string)

      return unauthorized("Invalid access token") unless access_token&.accessible?

      user = User.includes(role: :permissions).find(access_token.resource_owner_id)

      return bad_request("User not found", "Associated user not found") unless user

      success({
        id: user.id,
        email: user.email,
        role: user.role.name,
        permissions: user.role.permissions.map(&:name)
      }, "User retrieved successfully")
    rescue StandardError => e
      internal_server_error("An unexpected error occurred while retrieving user", [ e.message ])
    end
  end

  def refresh_token
    begin
      refresh_token = read_refresh_token

      return unauthorized("Please provide a valid refresh token") unless refresh_token

      token = Doorkeeper::AccessToken.by_refresh_token(refresh_token)

      return bad_request("Invalid refresh token", "Refresh token is invalid or expired") unless token&.refresh_token && token.refresh_token == refresh_token

      unless token.revoked?
        token.revoke
        token.save!
      end

      new_token = Doorkeeper::AccessToken.create(
        application: token.application,
        resource_owner_id: token.resource_owner_id,
        scopes: token.scopes,
        expires_in: 2.hours,
        use_refresh_token: true
      )

      set_refresh_token(new_token.refresh_token)

      success({
        access_token: new_token.token,
        expires_in: new_token.expires_in
      }, "Access token refreshed successfully")
    rescue StandardError => e
      internal_server_error("An unexpected error occurred while refreshing token", [ e.message ])
    end
  end

  def logout
    refresh_token = read_refresh_token

    cookies.delete(:refresh_token, secure: Rails.env.production?, same_site: :strict)

    if refresh_token
      token = Doorkeeper::AccessToken.by_refresh_token(refresh_token)
      token&.revoke
    end

    success(nil, "Logged out successfully")
  end

  private

  def read_refresh_token
    Rails.env.production? ? cookies.encrypted[:refresh_token] : cookies[:refresh_token]
  end

  def set_refresh_token(token)
    cookie_store = Rails.env.production? ? cookies.encrypted : cookies
    cookie_store[:refresh_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict,
      expires: 30.days.from_now
    }
  end
end

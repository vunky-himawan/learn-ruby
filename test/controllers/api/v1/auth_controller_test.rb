require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @role = Role.create!(name: "Register Role")
    @user_params = {
      email: "test@example.com",
      password: "password",
      role_id: @role.id
    }
    @client_app = Doorkeeper::Application.create!(
      name: "TestApp",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      scopes: "public"
    )
  end

  test "should register user with valid params" do
    assert_difference("User.count", 1) do
      post api_v1_auth_register_url, params: @user_params
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "User created successfully", json_response["message"]
    assert_equal @user_params[:email], json_response["data"]["email"]
  end

  test "should not register user with existing email" do
    User.create!(@user_params)

    assert_no_difference("User.count") do
      post api_v1_auth_register_url, params: @user_params
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Validation failed", json_response["message"]
    assert_equal [ "Email has already been taken" ], json_response["errors"]
  end

  test "should not register user without role" do
    @user_params.delete(:role_id)

    assert_no_difference("User.count") do
      post api_v1_auth_register_url, params: @user_params
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    assert_equal [ "Role must exist" ], json_response["errors"]
    assert_equal "Validation failed", json_response["message"]
  end

  test "should not register user with invalid role" do
    @user_params[:role_id] = -1 # Assuming this role does not exist

    assert_no_difference("User.count") do
      post api_v1_auth_register_url, params: @user_params
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    assert_equal [ "Role must exist" ], json_response["errors"]
    assert_equal "Validation failed", json_response["message"]
  end

  test "should login user with valid credentials" do
    user = User.create!(@user_params)

    post api_v1_auth_login_url, params: {
      email: user.email,
      password: user.password,
      client_id: @client_app.uid
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    data = json_response["data"]
    assert data["access_token"].present?
    assert_equal 7200, data["expires_in"] # 2 hours in seconds
  end

  test "should not login with invalid credentials" do
    post api_v1_auth_login_url, params: {
      email: "invalid@example.com",
      password: "wrongpassword",
      client_id: @client_app.uid
    }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid credentials", json_response["message"]
    assert_equal "Email or password is incorrect", json_response["errors"]
  end

  test "should refresh token with valid refresh_token in cookies" do
    user = User.create!(@user_params)

    access_token = Doorkeeper::AccessToken.create!(
      application_id: @client_app.id,
      resource_owner_id: user.id,
      expires_in: 2.hours,
      scopes: "public",
      use_refresh_token: true
    )

    cookies[:refresh_token] = access_token.refresh_token

    post api_v1_auth_refresh_token_url

    assert_response :success
    json_response = JSON.parse(response.body)
    data = json_response["data"]

    assert data["access_token"].present?
    assert_equal 7200, data["expires_in"]
    assert_equal "Access token refreshed successfully", json_response["message"]
  end

  test "should not refresh token without refresh_token in cookies" do
    post api_v1_auth_refresh_token_url

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Please provide a valid refresh token", json_response["message"]
  end

  test "should logout and clear refresh token" do
    user = User.create!(@user_params)

    access_token = Doorkeeper::AccessToken.create!(
      application_id: @client_app.id,
      resource_owner_id: user.id,
      expires_in: 2.hours,
      use_refresh_token: true
    )

    cookies[:refresh_token] = access_token.refresh_token

    delete api_v1_auth_logout_url

    assert_response :success
    assert_nil response.headers["Set-Cookie"]

    json_response = JSON.parse(response.body)
    assert_equal "Logged out successfully", json_response["message"]
  end

  test "should get current user with me endpoint" do
    user = User.create!(@user_params)
    access_token = Doorkeeper::AccessToken.create!(
      application_id: @client_app.id,
      resource_owner_id: user.id,
      expires_in: 2.hours,
      scopes: "public"
    )

    get api_v1_auth_me_url, headers: {
      "Authorization" => "Bearer #{access_token.token}"
    }

    assert_response :success
    json_response = JSON.parse(response.body)

    data = json_response["data"]

    assert_equal user.email, data["email"]
    assert_equal @role.name, data["role"]
  end

  test "should not get me with invalid token" do
    get api_v1_auth_me_url, headers: {
      "Authorization" => "Bearer invalidtoken"
    }

    assert_response :unauthorized
  end
end

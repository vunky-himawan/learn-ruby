require "test_helper"

class OauthFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @role = Role.create!(name: "AdminBaru")
    @user = User.create!(email: "email@gmail.com", password: "password", role_id: @role.id)
    @app = Doorkeeper::Application.create!(name: "TestApp", redirect_uri: "urn:ietf:wg:oauth:2.0:oob")
  end

  test "can get access token with valid credentials" do
    post "/oauth/token", params: {
      "grant_type": "password",
      "username": @user.email,
      "password": "password",
      "client_id": @app.uid,
      "client_secret": @app.secret
    }

    assert_response :success
    body = json_response
    assert body["access_token"].present?
    assert_equal "bearer", body["token_type"].downcase
  end

  test "cannot get token with invalid password" do
    post "/oauth/token", params: {
      grant_type: "password",
      username: @user.email,
      password: "wrongpassword",
      client_id: @app.uid,
      client_secret: @app.secret
    }

    assert_response :bad_request
    body = json_response
    assert body["status_code"].present?
    assert_equal 401, body["status_code"]
  end

  test "can revoke token" do
    token = create_access_token(@user, @app)
    assert token.token.present?

    post "/oauth/revoke", params: {
      token: token.token,
      client_id: @app.uid,
      client_secret: @app.secret
    }

    assert_response :success
  end

  private

  def create_access_token(user, app)
    Doorkeeper::AccessToken.create!(
      application_id: app.id,
      resource_owner_id: user.id,
      scopes: "",
      expires_in: 2.hours,
      use_refresh_token: true
    )
  end
end

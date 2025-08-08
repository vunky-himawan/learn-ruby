require 'rails_helper'

RSpec.describe Api::V1::Auth::AuthController, type: :controller do
  before do
    request.headers['Content-Type'] = 'application/json'
  end

  describe "POST #sign_in" do
    let(:password) { "password123" }
    let!(:user) { create(:user, password: password, password_confirmation: password) }

    context "with valid credentials" do
      let(:valid_params) do
        {
          email: user.email,
          password: password
        }
      end

      it "signs in the user successfully" do
        post :sign_in, params: valid_params

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)

        expect(body["statusCode"]).to eq(200)
        expect(body["message"]).to eq("User signed in successfully")
        expect(body["data"]).to include(
          "email" => user.email,
          "name" => user.name,
          "id" => user.id
        )
        expect(body["data"]["token"]).to be_present
      end

      it "sets refresh token cookie" do
        post :sign_in, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response.cookies["refresh_token"]).to be_present

        # Check cookie properties
        cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, response.cookies)
        expect(cookie_jar["refresh_token"]).to be_present
      end

      it "returns token with correct data" do
        post :sign_in, params: valid_params

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        token = body["data"]["token"]

        expect(token).to be_present

        token_data = decode_jwt(token)

        expect(token_data["user_id"] || token_data[:user_id]).to eq(user.id)
        expect(token_data["email"] || token_data[:email]).to eq(user.email)

        # Check token expiration
        exp_time = token_data["exp"] || token_data[:exp]
        expect(Time.at(exp_time)).to be > Time.current if exp_time
      end

      it "creates a refresh token record" do
        expect {
          post :sign_in, params: valid_params
        }.to change(RefreshToken, :count).by(1)

        refresh_token = RefreshToken.last
        expect(refresh_token.user).to eq(user)
        expect(refresh_token.expires_at).to be > Time.current
      end
    end

    context "with invalid credentials" do
      let(:invalid_params) do
        {
            email: user.email,
            password: "wrongpassword"
        }
      end

      it "returns unauthorized status with invalid password" do
        post :sign_in, params: invalid_params

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)

        expect(body["statusCode"]).to eq(401)
        expect(body["message"]).to eq("Invalid email or password")
        expect(body["data"]).to be_nil
      end

      it "does not create refresh token with invalid credentials" do
        expect {
          post :sign_in, params: invalid_params
        }.not_to change(RefreshToken, :count)
      end
    end
    context "with missing email" do
      let(:missing_email_params) do
        {
          auth: {
            password: password
          }
        }
      end

      it "returns bad request status" do
        post :sign_in, params: missing_email_params

        expect(response).to have_http_status(:bad_request)

        body = JSON.parse(response.body)
        expect(body["statusCode"]).to eq(400)
      end
    end

    context "with missing password" do
      let(:missing_password_params) do
        {
          auth: {
            email: user.email
          }
        }
      end

      it "returns bad request status" do
        post :sign_in, params: missing_password_params

        expect(response).to have_http_status(:bad_request)

        body = JSON.parse(response.body)
        expect(body["statusCode"]).to eq(400)
      end
    end

    context "with non-existent email" do
      let(:non_existent_params) do
        {
            email: "nonexistent@example.com",
            password: password
        }
      end

      it "returns unauthorized status" do
        post :sign_in, params: non_existent_params

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body["statusCode"]).to eq(401)
        expect(body["message"]).to eq("Invalid email or password")
      end
    end
  end
end

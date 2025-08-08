require 'rails_helper'

RSpec.describe Api::V1::Auth::AuthController, type: :controller do
  let(:role) { create(:role) }
  let(:user) { create(:user, role: role) }

  before do
    request.headers['Content-Type'] = 'application/json'
  end

  describe "POST #sign_up" do
    let(:valid_params) do
      {
        name: "John Doe",
        email: Faker::Internet.unique.email,
        password: "password123",
        password_confirmation: "password123",
        role_id: role.id
      }
    end

    it "creates a new user" do
      expect {
        post :sign_up, params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(201)
      expect(json["message"]).to eq("User created successfully")
      expect(json["data"]).to include(
        "email" => valid_params[:email],
        "name" => valid_params[:name]
      )
    end

    it "returns a 422 status code if the email is already taken" do
      existing_user = create(:user, role: role)

      duplicated_attributes = attributes_for(:user, email: existing_user.email).merge(role_id: role.id)

      post :sign_up, params: duplicated_attributes

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User creation failed")
      expect(json["errors"]).to include(
        { "attribute" => "email", "error" => "has already been taken" }
      )
    end

    it "returns a 422 status code if the password is too short" do
      invalid_attributes = attributes_for(:user, password: "123", password_confirmation: "123").merge(role_id: role.id)

      post :sign_up, params: invalid_attributes

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User creation failed")
      expect(json["errors"]).to include(
        { "attribute" => "password", "error" => "is too short (minimum is 8 characters)" }
      )
    end

    it "returns a 422 status code if the password confirmation doesn't match" do
      invalid_attributes = attributes_for(:user, password: "password123", password_confirmation: "password124").merge(role_id: role.id)

      post :sign_up, params: invalid_attributes

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User creation failed")
      expect(json["errors"]).to include(
        { "attribute" => "password_confirmation", "error" => "doesn't match Password" }
      )
    end

    it "returns a 422 status code if the role_id is invalid" do
      invalid_attributes = attributes_for(:user, role_id: -10)

      post :sign_up, params: invalid_attributes

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User creation failed")
      expect(json["errors"]).to include(
        { "attribute" => "role", "error" => "must exist" }
      )
    end

    it "returns a 400 status code if the name is missing" do
      invalid_attributes = attributes_for(:user, name: nil).merge(role_id: role.id)

      post :sign_up, params: invalid_attributes

      expect(response).to have_http_status(:bad_request)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: name")
    end
  end
end

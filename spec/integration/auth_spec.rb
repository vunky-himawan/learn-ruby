require "swagger_helper"

RSpec.describe "Auth API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/auth/register" do
    post("Register a new user") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        required: [ :name, :email, :password, :password_confirmation, :role_id ],
        properties: {
          user: {
            name: { type: :string, example: "John Doe" },
            email: { type: :string, format: "email", example: "john.doe@example.com" },
            password: { type: :string, example: "password123" },
            password_confirmation: { type: :string, example: "password123" },
            role_id: { type: :integer, example: 1 }
          }
        }
      }

      response(201, "User created successfully") do
        let!(:role) { create(:role) }

        let(:user) do
          {
            user: {
              name: "John Doe",
              email: "john.doe@example.com",
              password: "password123",
              password_confirmation: "password123",
              role_id: role.id
            }
          }
        end

        run_test!
      end

      response(422, "User couldn't be created successfully") do
        let(:user) do
          {
            user: {
              name: "422 John Doe",
              email: "john.doe@example.com",
              password: "password123",
              password_confirmation: "password123",
              role_id: nil
            }
          }
        end

        run_test!
      end
    end
  end
end

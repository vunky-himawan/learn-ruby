
module Auth
    class UserLoginService
      include ActionController::Cookies

      def initialize(email:, password:, client_id:)
        @email = email
        @password = password
        @client_id = client_id
      end

      def call
        user = User.find_by(email: email)
        application = Doorkeeper::Application.find_by(uid: client_id)

        credentials = Doorkeeper::AccessToken.create!(
          application_id: application.id,
          resource_owner_id: user.id,
          expires_in: 2.hours,
          scopes: "public",
          use_refresh_token: true
        )

        credentials
      end

      private

      attr_reader :email, :password, :client_id
    end
end

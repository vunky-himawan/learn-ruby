
module Auth
    class UserLoginService
      include TokenHelper

      def initialize(email:, password:, client_id:, cookies:)
        @email = email
        @password = password
        @client_id = client_id
        @cookies = cookies
      end

      def call
        user = User.find_by(email: email)
        application = Doorkeeper::Application.find_by(uid: client_id)

        credentials = create_token(
          user.id,
          application.id
        )

        set_refresh_token_cookie(credentials.refresh_token, cookies)

        credentials
      end

      private

      attr_reader :email, :password, :client_id, :cookies
    end
end

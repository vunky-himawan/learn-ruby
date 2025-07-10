
module Auth
    class UserLogoutService
      include TokenHelper

      def initialize(cookies:)
        @cookies = cookies
      end

      def call
        refresh_token = read_refresh_token(cookies)

        if refresh_token
          token = Doorkeeper::AccessToken.by_refresh_token(refresh_token)

          if token && token.resource_owner_id == token.resource_owner_id
            revoke_token(token)
          end
        end

        delete_refresh_token_cookie(cookies)
      end

      private

      attr_reader :cookies
    end
end

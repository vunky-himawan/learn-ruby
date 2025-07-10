module Auth
  class RefreshTokenService
    include TokenHelper

    def initialize(cookies:)
      @cookies = cookies
    end

    def call
      refresh_token = read_refresh_token(cookies)

      raise Errors::UnauthorizedError, "Please provide a valid refresh token" unless refresh_token

      token = Doorkeeper::AccessToken.by_refresh_token(refresh_token)

      raise Errors::BadRequestError, "Invalid refresh token" unless token&.refresh_token && token.refresh_token == refresh_token

      revoke_token(token)

      new_token = create_token(
        token.resource_owner_id,
        token.application_id,
        scopes: token.scopes,
      )

      set_refresh_token_cookie(new_token.refresh_token, cookies)

      new_token
    end

    private

    attr_reader :cookies
  end
end

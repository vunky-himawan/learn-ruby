module Auth
  class RefreshTokenService
    include TokenHelper

    def initialize(token:, cookies:)
      @token = token
      @cookies = cookies
    end

    def call
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

    attr_reader :token, :cookies
  end
end

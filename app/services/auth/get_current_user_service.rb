module Auth
  class UnauthorizedError < StandardError; end
  class NotFoundError < StandardError; end

  class GetCurrentUserService
    include TokenHelper

    def initialize(token_string:)
      @token_string = token_string
    end

    def call
      raise Auth::UnauthorizedError, "No access token provided" if token_string.blank?

      access_token = Doorkeeper::AccessToken.by_token(token_string)

      raise Auth::UnauthorizedError, "Invalid or expired access token" unless access_token&.accessible?

      user = User.includes(role: :permissions).find_by(id: access_token.resource_owner_id)

      raise Auth::NotFoundError, "User not found" unless user

      {
        id: user.id,
        email: user.email,
        role: user.role.name,
        permissions: user.role.permissions.map(&:name)
      }
    end

    private

    attr_reader :token_string
  end
end

module Auth
  class GetCurrentUserService
    include TokenHelper

    def initialize(token_string:)
      @token_string = token_string
    end

    def call
      raise Errors::UnauthorizedError, "No access token provided" if token_string.blank?

      access_token = Doorkeeper::AccessToken.by_token(token_string)

      raise Errors::UnauthorizedError, "Invalid or expired access token" unless access_token&.accessible?

      user = User.includes(role: :permissions).find_by(id: access_token.resource_owner_id)

      raise Errors::NotFoundError, "User not found" unless user

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

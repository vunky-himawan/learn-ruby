
module Auth
    class UserRegistrationService
      def initialize(email:, password:, role_id:)
        @email = email
        @password = password
        @role_id = role_id
      end

      def call
        user = User.create!(
          email: email,
          password: password,
          role_id: role_id
        )

        user
      end

      private

      attr_reader :email, :password, :role_id
    end
end

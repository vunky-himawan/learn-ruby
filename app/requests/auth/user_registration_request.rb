module Auth
  class UserRegistrationRequest
    include ActiveModel::Model

    attr_accessor :email, :password, :role_id

    validates :email, presence: true
    validates :password, presence: true, length: { minimum: 6 }
    validate :email_must_be_unique
    validate :role_presence_and_valid

    private

    def email_must_be_unique
      if User.exists?(email: email)
        errors.add(:email, "has already been taken")
      end
    end

    def role_presence_and_valid
      if role_id.blank?
        errors.add(:role, "is required")
      elsif !Role.exists?(role_id)
        errors.add(:role, "must exist")
      end
    end
  end
end

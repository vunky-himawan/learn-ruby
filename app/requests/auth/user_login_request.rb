module Auth
  class UserLoginRequest
    include ActiveModel::Model

    attr_accessor :email, :password, :client_id

    validates :email, presence: true
    validates :password, presence: true, length: { minimum: 6 }
    validates :client_id, presence: true
    validate :client_id_must_be_valid
    validate :credentials_must_be_valid

    private

    def client_id_must_be_valid
      application = Doorkeeper::Application.find_by(uid: client_id)
      unless application
        errors.add(:client_id, "must be a valid client ID")
      end
    end

    def credentials_must_be_valid
      user = User.find_by(email: email)

      unless user&.authenticate(password)
        errors.add(:base, "Invalid email or password")
      end
    end
  end
end

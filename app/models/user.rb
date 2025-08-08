class User < ApplicationRecord
  has_secure_password
  belongs_to :role

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_email_format
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validates :role, presence: true
  validates :password, length: { minimum: 8 }

  private

  def validate_email_format
    unless Validators::EmailValidator.validate(email)
      errors.add(:email, "format is invalid")
    end
  end
end

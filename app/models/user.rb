class User < ApplicationRecord
  include SoftDeleteable

  has_secure_password

  belongs_to :role, optional: true

  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true, length: { minimum: 6 }
  validate :role_presence_and_valid

  private

  def role_presence_and_valid
    if role_id.blank?
      errors.add(:role, "is required")
    elsif !Role.exists?(role_id)
      errors.add(:role, "must exist")
    end
  end
end

class User < ApplicationRecord
  include SoftDeleteable

  has_secure_password

  belongs_to :role

  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true, length: { minimum: 6 }
  validates :role_id, presence: true, inclusion: { in: ->(_) { Role.pluck(:id) }, message: "must be a valid role" }
end

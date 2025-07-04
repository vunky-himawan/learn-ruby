class Role < ApplicationRecord
  include SoftDeleteable

  has_many :users
  has_many :role_permissions, class_name: "RolePermission"
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true
end

class Permission < ApplicationRecord
  has_many :role_has_permissions, class_name: "RolePermission"
  has_many :roles, through: :role_has_permissions

  validates :name, presence: true, uniqueness: true
end

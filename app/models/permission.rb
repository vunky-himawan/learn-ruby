class Permission < ApplicationRecord
  has_and_belongs_to_many :roles, join_table: :role_has_permissions
end

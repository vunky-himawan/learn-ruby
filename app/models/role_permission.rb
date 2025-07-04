class RolePermission < ApplicationRecord
  self.table_name = "role_has_permissions"

  belongs_to :role
  belongs_to :permission

  validates :role_id,
            presence: true,
            inclusion: { in: ->(_) { Role.pluck(:id) }, message: "must be a valid role" },
            uniqueness: { scope: :permission_id }

  validates :permission_id,
            presence: true,
            uniqueness: { scope: :role_id },
            inclusion: { in: ->(_) { Permission.pluck(:id) }, message: "must be a valid permission" }
end

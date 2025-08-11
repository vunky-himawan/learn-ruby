class CreateRoleHasPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :role_has_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.index [:role_id, :permission_id], unique: true
    end
  end
end

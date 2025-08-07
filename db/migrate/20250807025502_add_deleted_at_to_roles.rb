class AddDeletedAtToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :deleted_at, :datetime
  end
end

class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end

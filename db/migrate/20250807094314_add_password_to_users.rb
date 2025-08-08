class AddPasswordToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password, :string, null: false
  end
end

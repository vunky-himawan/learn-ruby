class RemoveDeviseColumnsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_columns :users, :encrypted_password
  end
end

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end

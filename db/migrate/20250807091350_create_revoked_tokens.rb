class CreateRevokedTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :revoked_tokens do |t|
      t.string :jti, null: false
      t.datetime :expired_at, null: false
      t.timestamps
    end
  end
end

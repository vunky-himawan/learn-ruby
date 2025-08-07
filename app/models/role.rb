class Role < ApplicationRecord
  has_many :users, dependent: :destroy
  has_and_belongs_to_many :permissions, join_table: :role_has_permissions

  validates :name, presence: true, uniqueness: true
end

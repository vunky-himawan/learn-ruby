FactoryBot.define do
  factory :user do
    association :role
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
  end
end

FactoryBot.define do
  factory :refresh_token do
    association :user
    token { SecureRandom.hex(64) }
    expires_at { 30.days.from_now }
  end
end

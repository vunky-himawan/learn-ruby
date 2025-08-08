require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:role) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_confirmation_of(:password) }
    it { should validate_length_of(:password).is_at_least(8) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value("john.doe@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }
  end
end

require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  let(:role) { create(:role) }
  let(:user) { create(:user, role: role) }

  describe 'validations' do
    # Create a subject for uniqueness validation test
    subject { create(:refresh_token, user: user) }

    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:expires_at) }
    it { should validate_uniqueness_of(:token) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'token generation' do
    let(:refresh_token) do
      RefreshToken.create!(
        user: user,
        token: SecureRandom.hex(64),
        expires_at: 30.days.from_now
      )
    end

    it 'generates a unique token' do
      expect(refresh_token.token).to be_present
      expect(refresh_token.token.length).to eq(128)
    end

    it 'associates with the user' do
      expect(refresh_token.user).to eq(user)
    end

    it 'sets an expiration date' do
      expect(refresh_token.expires_at).to be_present
      expect(refresh_token.expires_at).to be > Time.current
    end
  end

  describe 'expiration behavior' do
    it 'can check if token is expired manually' do
      expired_token = create(:refresh_token, user: user, expires_at: 1.day.ago)
      valid_token = create(:refresh_token, user: user, expires_at: 1.day.from_now)

      expect(expired_token.expires_at).to be < Time.current
      expect(valid_token.expires_at).to be > Time.current
    end
  end
end

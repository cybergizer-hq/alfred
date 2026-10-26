require 'rails_helper'

RSpec.describe User, type: :model do
  context 'with valid attributes' do
    subject(:user) { create :user }

    it { is_expected.to be_valid }
  end

  context 'with invalid attributes' do
    subject(:invalid_user) { build :user, :without_dob }

    it { is_expected.not_to be_valid }
  end

  context 'with associations' do
    it { is_expected.to have_many(:app_admissions).dependent(:destroy) }
    it { is_expected.to have_many(:oauth_applications).through(:app_admissions) }
    it { is_expected.to have_one_attached(:avatar) }
    it { is_expected.to accept_nested_attributes_for(:app_admissions) }
  end

  context 'with validations' do
    it { is_expected.to validate_presence_of(:dob) }
  end

  describe '#active_for_authentication?' do
    it 'is true for an active user' do
      expect(build(:user)).to be_active_for_authentication
    end

    it 'is false for a deactivated user' do
      expect(build(:user, :deactivated)).not_to be_active_for_authentication
    end
  end

  describe '#inactive_message' do
    it 'is :inactive for a deactivated user' do
      expect(build(:user, :deactivated).inactive_message).to eq(:inactive)
    end
  end

  describe 'revoking OAuth credentials on deactivation' do
    let(:user) { create(:user) }
    let!(:token) { create(:access_token, resource_owner_id: user.id) }
    let!(:grant) { create(:access_grant, resource_owner_id: user.id) }

    it "revokes the user's access tokens" do
      user.update!(deactivated_at: Time.current)
      expect(token.reload).to be_revoked
    end

    it "revokes the user's access grants" do
      user.update!(deactivated_at: Time.current)
      expect(grant.reload).to be_revoked
    end

    it "leaves other users' tokens alone" do
      other_token = create(:access_token, resource_owner_id: create(:user).id)
      user.update!(deactivated_at: Time.current)
      expect(other_token.reload).not_to be_revoked
    end

    it 'does not revoke tokens on unrelated updates' do
      user.update!(first_name: 'Renamed')
      expect(token.reload).not_to be_revoked
    end

    it 'keeps the original revocation time of already revoked tokens' do
      revoked_at = 1.day.ago.change(usec: 0)
      token.update!(revoked_at:)
      user.update!(deactivated_at: Time.current)
      expect(token.reload.revoked_at).to eq(revoked_at)
    end
  end
end

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
end

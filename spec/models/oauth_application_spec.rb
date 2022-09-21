require 'rails_helper'

RSpec.describe OauthApplication, type: :model do
  context 'with valid attributes' do
    subject(:oauth_application) { create :oauth_application }

    it { is_expected.to be_valid }
  end

  context 'with invalid attributes' do
    subject(:oauth_application) { build :oauth_application, :without_redirect_uri }

    it { is_expected.not_to be_valid }
  end

  context 'with associations' do
    it { is_expected.to have_many(:app_admissions).dependent(:destroy) }
  end
end

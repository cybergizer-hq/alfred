require 'rails_helper'

RSpec.describe AppAdmission, type: :model do
  context 'with associations' do
    it { is_expected.to belong_to(:oauth_application) }
    it { is_expected.to belong_to(:user) }
  end
end

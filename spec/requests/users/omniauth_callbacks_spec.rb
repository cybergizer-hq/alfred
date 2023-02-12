require 'rails_helper'

RSpec.describe 'users/auth', type: :request do
  describe 'POST /discord' do
    it 'creates user with discord' do
      lambda do
        discord_hash
        post user_discord_omniauth_callback_url
        expect(response).to redirect_to(root_url)
      end.should change(User, :count).by(1)
    end
  end
end

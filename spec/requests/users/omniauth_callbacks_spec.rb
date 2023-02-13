require 'rails_helper'

RSpec.describe 'users/auth', type: :request do
  describe 'POST /discord' do
    before do
      Users::OmniauthCallbacksController.skip_before_action :authorize_guild_member
    end

    it 'creates user with discord', skip_before: true do
      lambda do
        discord_hash
        post user_discord_omniauth_callback_url
        expect(response).to redirect_to(root_url)
      end.should change(User, :count).by(1)
    end
  end
end

require 'rails_helper'

RSpec.describe 'users/auth', type: :request do
  describe 'POST /yandex' do
    it 'creates user with yandex' do
      lambda do
        yandex_hash
        post user_yandex_omniauth_callback_url
        expect(response).to redirect_to(root_url)
      end.should change(User, :count).by(1)
    end
  end
end

require 'rails_helper'

RSpec.describe '/', type: :request do
  before { sign_in user }

  describe 'GET /login' do
    let(:user) { create(:user) }

    it 'returns a 200 status code' do
      get login_url
      expect(response).to have_http_status(200)
    end

    it 'renders the login template' do
      get login_url
      expect(subject).to render_template('application/login')
    end
  end
end

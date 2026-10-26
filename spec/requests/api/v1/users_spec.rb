require 'rails_helper'

RSpec.describe 'api/v1/users', type: :request do
  describe 'GET /api/v1/users/me' do
    let(:user) { create(:user) }
    let!(:access_token) { create(:access_token, resource_owner_id: user.id) }

    def request_me
      get api_v1_users_me_url, headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    it "returns an active user's profile" do
      request_me
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['id']).to eq(user.id)
    end

    context 'when the user is deactivated' do
      before { user.update!(deactivated_at: Time.current) }

      it 'rejects the token' do
        request_me
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is deactivated without callbacks' do
      before do
        user.update_column(:deactivated_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
      end

      it 'rejects the token even though it was not revoked' do
        request_me
        expect(access_token.reload).not_to be_revoked
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user has been deleted' do
      before { user.destroy }

      it 'rejects the token' do
        request_me
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /oauth/userinfo' do
    let(:user) { create(:user) }
    let!(:access_token) { create(:access_token, resource_owner_id: user.id, scopes: 'openid') }

    it 'rejects the token of a deactivated user' do
      user.update!(deactivated_at: Time.current)
      get '/oauth/userinfo', headers: { 'Authorization' => "Bearer #{access_token.token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

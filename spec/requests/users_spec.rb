require 'rails_helper'

RSpec.describe '/users', type: :request do
  describe 'GET /show' do
    before { sign_in user }
    let(:user) { create(:user) }

    it 'renders a successful response' do
      get user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    before { sign_in user }
    let(:user) { create(:user) }

    it 'renders a successful response' do
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    before { sign_in user }
    let(:user) { create(:user) }

    context 'with valid parameters' do
      let(:new_attributes) { attributes_for(:user) }

      it 'updates the requested user' do
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(user.email).to eq(new_attributes[:email])
      end

      it 'redirects to the user' do
        patch user_url(user), params: { user: new_attributes }
        expect(response).to redirect_to(user_url(user))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { attributes_for(:user, :without_dob) }

      it 'renders a successful response' do
        patch user_url(user), params: { user: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /invite' do
    before { sign_in user }
    let(:user) { create(:user) }
    let(:email) { Faker::Internet.email }

    it 'redirects to the admin' do
      post create_invitation_url, params: { email: email }
      expect(response).to redirect_to(admin_users_url)
    end
  end

  describe 'POST /invite_self' do
    before { sign_in user }
    let(:user) { create(:user) }

    context 'with valid email' do
      let(:email) { user.email }

      it 'redirects to root' do
        post create_self_invitation_url, params: { email: email }
        expect(response).to redirect_to(root_url)
      end

      it 'sends flash notice' do
        post create_self_invitation_url, params: { email: email }
        expect(flash[:notice]).to eq('The link was sent to your email')
      end
    end

    context 'with invalid email' do
      let(:email) { Faker::Internet.email }

      it 'redirects to root' do
        post create_self_invitation_url, params: { email: email }
        expect(response).to redirect_to(root_url)
      end

      it 'sends flash alert' do
        post create_self_invitation_url, params: { email: email }
        expect(flash[:alert]).to eq('This e-mail is not present in our DB')
      end
    end
  end

  describe 'GET /magic_login' do
    let(:token) { Faker::Lorem.characters }

    context 'with existing user' do
      it 'redirects to the user and clears token' do
        user = create(:user, magic_link_token: token)
        get email_link_url, params: { token: token }
        expect(response).to redirect_to(user_url(user))
      end

      it 'clears the user token' do
        user = create(:user, magic_link_token: token)
        get email_link_url, params: { token: token }
        user.reload
        expect(user.magic_link_token).to be_nil
      end
    end

    context 'with a nonexistent user' do
      it 'redirects to the login' do
        get email_link_url, params: { token: token }
        expect(response).to redirect_to(root_url)
      end

      it 'sends flash alert' do
        get email_link_url, params: { token: token }
        expect(flash[:alert]).to eq('Your token is invalid')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'admin/users', type: :request do
  before { sign_in admin }
  let(:admin) { create(:user, :admin) }

  let(:user) { create(:user) }
  let(:attributes) { attributes_for(:user) }
  let(:invalid_attributes) { attributes_for(:user, :without_dob) }

  describe 'GET /index' do
    it 'renders a successful response' do
      get admin_users_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      get edit_admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_admin_user_url
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'updates the requested user' do
        patch admin_user_url(user), params: { user: attributes }
        user.reload
        expect(user.email).to eq(attributes[:email])
      end

      it 'redirects to the user' do
        patch admin_user_url(user), params: { user: attributes }
        expect(response).to redirect_to(admin_user_url(user))
      end
    end

    context 'with invalid parameters' do
      it 'renders a successful response' do
        patch admin_user_url(user), params: { user: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          post admin_users_url, params: { user: attributes }
        end.to change(User, :count).by(1)
      end

      it 'redirects to the created user' do
        post admin_users_url, params: { user: attributes }
        expect(response).to redirect_to(admin_user_url(User.last))
      end

      it 'sends flash notice' do
        post admin_users_url, params: { user: attributes }
        expect(flash[:notice]).to eq('User was successfully created.')
      end
    end

    context 'with invalid parameters' do
      it "doesn't create a new user" do
        expect do
          post admin_users_url, params: { user: invalid_attributes }
        end.to change(User, :count).by(0)
      end

      it 'renders a successful response' do
        post admin_users_url, params: { user: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested user' do
      new_user = create(:user)
      expect do
        delete admin_user_url(new_user)
      end.to change(User, :count).by(-1)
    end

    it 'redirects to users' do
      delete admin_user_url(user)
      expect(response).to redirect_to(admin_users_url)
    end

    it 'sends flash notice' do
      delete admin_user_url(user)
      expect(flash[:notice]).to eq('User was deleted.')
    end
  end

  describe 'PUT /deactivate' do
    it 'redirects to the updated user' do
      put admin_deactivate_user_url(user)
      expect(response).to redirect_to(admin_user_url(user))
    end

    it 'removes oauth_applications from user' do
      put admin_deactivate_user_url(user)
      user.reload
      expect(user.oauth_application_ids).to eq([])
    end

    it 'sends flash notice' do
      put admin_deactivate_user_url(user)
      expect(flash[:notice]).to eq('User was successfully deactivated.')
    end
  end

  describe 'PUT /activate' do
    it 'redirects to the updated user' do
      put admin_activate_user_url(user)
      expect(response).to redirect_to(admin_user_url(user))
    end

    it 'removes deactivated_at from user' do
      put admin_activate_user_url(user)
      user.reload
      expect(user.deactivated_at).to be_nil
    end

    it 'sends flash notice' do
      put admin_activate_user_url(user)
      expect(flash[:notice]).to eq('User was successfully activated.')
    end
  end
end

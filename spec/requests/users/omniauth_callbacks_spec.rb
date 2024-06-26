require 'rails_helper'

RSpec.describe 'users/auth', type: :request do
  describe 'POST /discord' do
    let(:action) { post user_discord_omniauth_callback_url }

    before do
      expect(Discord::GuildMemberValidator).to receive(:call).and_return(true)
    end

    context 'when user exists' do
      let(:user) { create(:user) }
      let(:auth_email) { user.email }
      let(:auth_name) { 'username' }

      before do
        OmniAuth.config.mock_auth[:discord] =
          OmniAuth::AuthHash.new({
            'uid': Faker::Number.number(digits: 6),
            'info': {
              'email': auth_email,
              'name': auth_name
            }
          })
      end

      it 'doesnt create user' do
        expect { action }.not_to change(User, :count)
      end

      it 'redirects to root_url' do
        action
        expect(response).to redirect_to(root_url)
      end

      context 'when user has first_name and last_name' do
        let(:first_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }
        let(:user) { create(:user, first_name: first_name, last_name: last_name ) }

        it 'doesnt change user.first_name' do
          action
          expect(user.reload.first_name).to eq(first_name)
        end

        it 'doesnt change user.last_name' do
          action
          expect(user.reload.last_name).to eq(last_name)
        end
      end

      context 'when user doesnt have first_name and last_name' do
        let(:user) { create(:user, first_name: '', last_name: '' ) }

        it 'first_name is set' do
          action
          expect(user.reload.first_name).to eq(auth_name)
        end

        it 'last_name isnt set' do
          action
          expect(user.reload.last_name).to eq('')
        end
      end

      context 'when OathApplications present' do
        let!(:oapp1) { create(:oauth_application) }
        let!(:oapp2) { create(:oauth_application) }

        context 'when there are no default_access oauth apps' do
          it 'doesnt change user.oauth_applications' do
            action
            expect(user.reload.oauth_applications).to be_empty
          end
        end

        context 'when there are default_access oauth apps' do
          let!(:oapp3) { create(:oauth_application, default_access: true) }

          context 'when user has oauth apps attached' do
            before do
              user.oauth_applications << oapp1
            end

            it 'doesnt change user.oauth_applications' do
              action
              expect(user.reload.oauth_applications).to eq([oapp1])
            end
          end

          context 'when user has no oauth apps attached' do
            it 'adds default_access oauth apps to user' do
              action
              expect(user.reload.oauth_applications).to eq([oapp3])
            end
          end
        end

      end
    end

    context 'when user doesnt exist' do
      let!(:other_user) { create(:user) }

      let(:auth_email) { Faker::Internet.email }
      let(:auth_name) { 'username' }

      let(:user) { User.find_by(email: auth_email)}

      before do
        OmniAuth.config.mock_auth[:discord] =
          OmniAuth::AuthHash.new({
            'uid': Faker::Number.number(digits: 6),
            'info': {
              'email': auth_email,
              'name': auth_name
            }
          })
      end

      it 'creates user' do
        expect { action }.to change(User, :count).by(1)
      end

      it 'redirects to root_url' do
        action
        expect(response).to redirect_to(root_url)
      end

      it 'first_name is set' do
        action
        expect(user.reload.first_name).to eq(auth_name)
      end

      it 'last_name isnt set' do
        action
        expect(user.reload.last_name).to eq('')
      end

      context 'when OathApplications present' do
        let!(:oapp1) { create(:oauth_application) }
        let!(:oapp2) { create(:oauth_application) }

        context 'when there are no default_access oauth apps' do
          it 'doesnt change user.oauth_applications' do
            action
            expect(user.oauth_applications).to be_empty
          end
        end

        context 'when there are default_access oauth apps' do
          let!(:oapp3) { create(:oauth_application, default_access: true) }

          it 'adds default_access oauth apps to user' do
            action
            expect(user.oauth_applications).to eq([oapp3])
          end
        end

      end
    end
  end
end

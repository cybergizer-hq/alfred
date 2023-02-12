# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!
    before_action :guild_member?

    def discord
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user
        set_flash_message(:notice, :success, kind: 'Discord') if is_navigational_format?
      else
        session['devise.discord_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url
      end
    end

    private

    def guild_member?
      return if Discord::GuildMemberValidator.new(guilds, ENV['CYBERGIZER_SERVER_ID']).call

      redirect_to root_path, notice: t('non_cybergizer_server_member_alert')
    end

    def guilds
      Discord::Guilds.new(request).call
    end
  end
end

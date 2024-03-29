# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!
    before_action :authorize_guild_member

    def discord
      @user = User.from_omniauth(request.env['omniauth.auth'])

      redirect_to root_path, notice: t('invalid_discord_user_alert') and return if @user.nil?

      if @user.persisted?
        sign_in_and_redirect @user
        set_flash_message(:notice, :success, kind: 'Discord') if is_navigational_format?
      else
        session['devise.discord_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url
      end
    end

    private

    def authorize_guild_member
      return if Discord::GuildMemberValidator.call(request)

      redirect_to root_path, notice: t('invalid_guild_member_alert')
    end
  end
end

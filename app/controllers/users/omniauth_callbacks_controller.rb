# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  before_action :non_cg_members

  def yandex
    user = from_omniauth(request.env['omniauth.auth'])
    sign_in(user)
    redirect_to after_sign_in_path_for(user)
  end

  private

  def non_cg_members
    email = request.env['omniauth.auth'].info.email
    return if email.include?('@cybergizer.com') || User.find_by(email: email)

    redirect_to login_url, notice: 'Only Cybergizer Members can log in'
  end

  def from_omniauth(auth)
    User.find_or_initialize_by(email: auth.info.email).tap |u| do
      u.uid = auth.uid
      u.first_name = auth.extra.raw_info.first_name if u.first_name.blank?
      u.last_name = auth.extra.raw_info.last_name if u.last_name.blank?

      u.save
    end
  end
end

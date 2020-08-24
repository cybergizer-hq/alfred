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
    User.where(email: auth.info.email).first_or_create do |user|
      user.first_name = auth.extra.raw_info.first_name
      user.last_name = auth.extra.raw_info.last_name
      user.dob = Date.parse('01-01-1970')
      user.uid = auth.uid
      user.email = auth.info.email
    end
  end
end

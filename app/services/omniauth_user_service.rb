# frozen_string_literal: true

# Process omniauth data to create or update user.
# Given auth hash, returns user object.
class OmniauthUserService
  def initialize(auth)
    @auth = auth
  end

  def call
    return if email.blank?

    assign_basic_attrs
    assign_names
    assign_oauth_applications

    user.save
    user
  end

  private

  attr_reader :auth

  def email
    @email ||= auth.info.email.downcase
  end

  def user
    @user ||= find_or_initialize_user
  end

  def find_or_initialize_user
    User.where(email:).or(User.where(alternative_email: email)).first_or_initialize
  end

  def assign_basic_attrs
    user.uid = auth.uid
    user.email = email if user.email.blank?
  end

  def assign_names
    return if [user.first_name, user.last_name].all?(&:present?)

    fullname = auth.info.name.split(/[.\s]/, 2)
    user.first_name, user.last_name = fullname.size.eql?(2) ? fullname : [*fullname, '']
  end

  def assign_oauth_applications
    user.oauth_applications << OauthApplication.default_access if user.oauth_applications.empty?
  end
end

class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?, except: :login

  before_action :authenticate_user!, except: :login

  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  def login; end

  private

  def authenticate_admin!
    return if current_user.admin?

    redirect_to login_url
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to login_path
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
end

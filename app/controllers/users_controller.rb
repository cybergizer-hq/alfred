# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  skip_before_action :authenticate_user!, only: %i[invite_self magic_login]

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Profile was successfully updated.'
    else
      render :edit
    end
  end

  def invite
    UserInviter.new(params[:email]).invite
    flash[:notice] = 'The link was sent'
    redirect_to admin_users_path
  end

  def invite_self
    if UserInviter.new(params[:email]).invite
      flash[:notice] = 'The link was sent to your email'
    else
      flash[:alert] = 'This e-mail is not present in our DB'
    end
    redirect_to root_path
  end

  def magic_login
    token = params[:token]
    user = User.find_by(magic_link_token: token) if token.is_a?(String) && token.present?
    consumed = user && user.deactivated_at.nil? &&
               User.where(id: user.id, magic_link_token: token)
                   .update_all(magic_link_token: nil) == 1

     if consumed
       sign_in(user, scope: :user)
       redirect_to user_path(user)
     else
      flash[:alert] = 'Your token is invalid'
      redirect_to root_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :dob, :avatar, :email)
  end
end

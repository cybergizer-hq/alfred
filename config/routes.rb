# frozen_string_literal: true

Rails.application.routes.draw do
  resources :email_links, only: [:create]
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  use_doorkeeper do
    controllers :applications => 'admin/custom_applications'
  end

  use_doorkeeper_openid_connect
  resources :users, only: %i[show edit update]
  namespace :admin do
    resources :users
    put 'users/deactivate/:id(.:format)', to: 'users#deactivate', as: :deactivate_user
    put 'users/activate/:id(.:format)', to: 'users#activate', as: :activate_user
  end
  post 'invite' => 'users#invite', as: :create_invitation
  post 'invite_self' => 'users#invite_self', as: :create_self_invitation
  get 'invite' => 'users#magic_login', as: :email_link

  namespace :api do
    namespace :v1 do
      get 'users/me'
    end
  end

  as :user do
    delete '/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  get '/login' => 'application#login', as: :login
  root to: 'users#show'
end

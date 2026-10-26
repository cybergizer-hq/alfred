FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    association :application, factory: :oauth_application
    expires_in { 2.hours.to_i }
  end

  factory :access_grant, class: 'Doorkeeper::AccessGrant' do
    association :application, factory: :oauth_application
    expires_in { 10.minutes.to_i }
    redirect_uri { application.redirect_uri }
  end
end

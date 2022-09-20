FactoryBot.define do
  factory :app_admission do
    association :user
    association :oauth_application
  end
end

FactoryBot.define do
  factory :oauth_application do
    name { Faker::App.name }
    redirect_uri { Faker::Internet.url.dup.insert(4, 's') }

    trait :without_redirect_uri do
      redirect_uri { nil }
    end
  end
end

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    dob { Faker::Date.between(from: '1970-01-21', to: '2005-01-01') }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :admin do
      is_admin { true }
    end

    trait :without_dob do
      dob { nil }
    end
  end
end

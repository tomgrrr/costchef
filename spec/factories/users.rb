# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    company_name { Faker::Company.name }
    subscription_active { false }
    admin { false }

    trait :subscribed do
      subscription_active { true }
    end

    trait :admin do
      admin { true }
    end

    trait :expired_subscription do
      subscription_active { false }
    end
  end
end

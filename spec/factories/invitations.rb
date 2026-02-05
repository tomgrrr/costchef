# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    sequence(:email) { |n| "invited#{n}@example.com" }
    association :created_by_admin, factory: [:user, :admin]

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :used do
      used_at { 1.hour.ago }
    end
  end
end

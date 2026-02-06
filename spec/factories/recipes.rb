# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    association :user
    sequence(:name) { |n| "Recette #{n}" }
    description { Faker::Food.description }

    trait :with_costs do
      cached_total_cost { 10.00 }
      cached_total_weight { 0.500 }
      cached_cost_per_kg { 20.00 }
    end
  end
end

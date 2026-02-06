# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    association :user
    sequence(:name) { |n| "Produit #{n}" }
    price { Faker::Commerce.price(range: 1.0..100.0) }
    unit { %w[kg L pièce].sample }

    trait :expensive do
      price { 100.0 }
    end

    trait :cheap do
      price { 1.0 }
    end
  end
end

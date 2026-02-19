# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'chef@test.fr' }
    password { 'password123' }
    markup_coefficient { 1.0 }
    subscription_active { true }
  end

  factory :supplier do
    name { 'Metro' }
    active { true }
    user
  end

  factory :product do
    name { 'Farine T55' }
    base_unit { 'kg' }
    avg_price_per_kg { 0 }
    user

    trait :piece do
      name { 'Oeuf' }
      base_unit { 'piece' }
      unit_weight_kg { 0.25 }
    end

    trait :liquid do
      name { 'Lait' }
      base_unit { 'l' }
    end
  end

  factory :product_purchase do
    package_quantity { 25 }
    package_price { 15.0 }
    package_unit { 'kg' }
    package_quantity_kg { 25.0 }
    price_per_kg { 0.6 }
    active { true }
    product
    supplier

    trait :in_grams do
      package_unit { 'g' }
      package_quantity { 500 }
      package_price { 3.0 }
      package_quantity_kg { 0.5 }
      price_per_kg { 6.0 }
    end

    trait :in_pieces do
      package_unit { 'piece' }
      package_quantity { 30 }
      package_price { 6.0 }
      package_quantity_kg { 1.8 }
      price_per_kg { 3.3333 }
    end

    trait :in_liters do
      package_unit { 'l' }
      package_quantity { 1 }
      package_price { 1.20 }
      package_quantity_kg { 1.0 }
      price_per_kg { 1.2 }
    end

    trait :in_cl do
      package_unit { 'cl' }
      package_quantity { 75 }
      package_price { 5.0 }
      package_quantity_kg { 0.75 }
      price_per_kg { 6.6667 }
    end

    trait :inactive do
      active { false }
    end

    trait :uncalculated do
      package_quantity_kg { 0.001 }
      price_per_kg { 0.0 }
    end
  end

  factory :recipe do
    name { 'Pâte brisée' }
    cooking_loss_percentage { 10 }
    sellable_as_component { false }
    cached_total_cost { 0 }
    cached_raw_weight { 0 }
    cached_total_weight { 0 }
    cached_cost_per_kg { 0 }
    user

    trait :subrecipe do
      name { 'Crème pâtissière' }
      sellable_as_component { true }
    end
  end

  factory :recipe_component do
    quantity_kg { 0.5 }
    quantity_unit { 'kg' }
    association :parent_recipe, factory: :recipe
    association :component, factory: :product

    trait :with_subrecipe do
      association :component, factory: %i[recipe subrecipe]
    end

    trait :in_grams do
      quantity_unit { 'g' }
    end

    trait :in_liters do
      quantity_unit { 'l' }
    end

    trait :in_pieces do
      quantity_unit { 'piece' }
    end
  end

  factory :invitation do
    email { 'invite@test.fr' }
    token { SecureRandom.urlsafe_base64(32) }
    expires_at { 7.days.from_now }
    used_at { nil }
    association :created_by_admin, factory: :user

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :used do
      used_at { 1.hour.ago }
    end

    trait :pending do
      used_at { nil }
      expires_at { 7.days.from_now }
    end
  end
end

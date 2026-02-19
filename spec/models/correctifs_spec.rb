# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeComponent, type: :model do
  let(:user)    { create(:user) }
  let(:recipe)  { create(:recipe, user: user) }
  let(:product) { create(:product, user: user) }

  describe 'quantity_unit validation' do
    it 'accepte les unités valides du PRD' do
      Units::VALID_UNITS.each do |unit|
        rc = build(:recipe_component,
                   parent_recipe: recipe,
                   component: product,
                   quantity_unit: unit)
        expect(rc).to be_valid, "#{unit} devrait être valide"
      end
    end

    it 'rejette une unité invalide' do
      rc = build(:recipe_component,
                 parent_recipe: recipe,
                 component: product,
                 quantity_unit: 'box')
      expect(rc).not_to be_valid
      expect(rc.errors[:quantity_unit]).to be_present
    end

    it 'rejette quantity_unit nil' do
      rc = build(:recipe_component,
                 parent_recipe: recipe,
                 component: product,
                 quantity_unit: nil)
      expect(rc).not_to be_valid
      expect(rc.errors[:quantity_unit]).to be_present
    end
  end
end

RSpec.describe ProductPurchase, type: :model do
  let(:user)     { create(:user) }
  let(:supplier) { create(:supplier, user: user) }
  let(:product)  { create(:product, user: user) }

  describe 'calculated fields validation' do
    it 'est invalide sans package_quantity_kg ni price_per_kg' do
      pp = build(:product_purchase, :uncalculated,
                 product: product, supplier: supplier,
                 package_quantity_kg: nil, price_per_kg: nil)
      expect(pp).not_to be_valid
      expect(pp.errors[:base]).to include(a_string_matching(/calculé/))
    end

    it 'est valide après passage par le service calculateur' do
      pp = build(:product_purchase, :uncalculated,
                 product: product, supplier: supplier,
                 package_unit: 'kg', package_quantity: 10, package_price: 20.0,
                 package_quantity_kg: nil, price_per_kg: nil)
      ProductPurchases::PricePerKgCalculator.call(pp)
      expect(pp).to be_valid
    end
  end

  describe 'package_unit validation' do
    it 'rejette une unité inconnue' do
      pp = build(:product_purchase,
                 product: product, supplier: supplier,
                 package_unit: 'barrel')
      pp.valid?
      expect(pp.errors[:package_unit]).to be_present
    end
  end
end

RSpec.describe Supplier, type: :model do
  let(:user)     { create(:user) }
  let(:supplier) { create(:supplier, user: user) }
  let(:product)  { create(:product, user: user) }

  describe '#force_destroy!' do
    before do
      create(:product_purchase, product: product, supplier: supplier,
                                package_quantity_kg: 10.0, price_per_kg: 2.0)
      Products::AvgPriceRecalculator.call(product)
    end

    it 'supprime le fournisseur et ses achats' do
      expect { supplier.force_destroy! }
        .to change(Supplier, :count).by(-1)
        .and change(ProductPurchase, :count).by(-1)
    end

    it 'recalcule le avg_price_per_kg du produit impacté à 0' do
      expect(product.reload.avg_price_per_kg.to_f).to eq(2.0)
      supplier.force_destroy!
      expect(product.reload.avg_price_per_kg.to_f).to eq(0.0)
    end
  end
end

RSpec.describe DailySpecial, type: :model do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'moyennes par catégorie' do
    before do
      create(:daily_special, user: user, category: 'meat',
             cost_per_kg: 10.0, entry_date: Date.today, item_name: 'Bœuf')
      create(:daily_special, user: user, category: 'meat',
             cost_per_kg: 20.0, entry_date: Date.today, item_name: 'Agneau')
      create(:daily_special, user: user, category: 'fish',
             cost_per_kg: 15.0, entry_date: Date.today, item_name: 'Saumon')
      create(:daily_special, user: other_user, category: 'meat',
             cost_per_kg: 100.0, entry_date: Date.today, item_name: 'Truffe')
    end

    it 'calcule la moyenne viande sans inclure les autres utilisateurs' do
      expect(user.daily_specials.meat_average).to eq(15.0)
    end

    it 'calcule la moyenne poisson' do
      expect(user.daily_specials.fish_average).to eq(15.0)
    end

    it 'retourne 0 si aucune entrée pour la catégorie' do
      expect(user.daily_specials.side_average).to eq(0)
    end

    it "isole les données par utilisateur" do
      expect(other_user.daily_specials.meat_average).to eq(100.0)
    end
  end
end

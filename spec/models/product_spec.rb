# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'validations' do
    context 'nom' do
      it 'est valide avec un nom présent' do
        product = build(:product, name: 'Farine T55', user: user)
        expect(product).to be_valid
      end

      it 'est invalide avec un nom vide' do
        product = build(:product, name: '', user: user)
        expect(product).not_to be_valid
        expect(product.errors[:name]).to be_present
      end

      it 'est invalide si doublon même user' do
        create(:product, name: 'Farine T55', user: user)
        product = build(:product, name: 'Farine T55', user: user)
        expect(product).not_to be_valid
        expect(product.errors[:name]).to be_present
      end

      it 'est valide si nom dupliqué autre user' do
        create(:product, name: 'Farine T55', user: other_user)
        product = build(:product, name: 'Farine T55', user: user)
        expect(product).to be_valid
      end
    end

    context 'base_unit' do
      %w[kg l piece].each do |unit|
        it "est valide avec base_unit #{unit}" do
          attrs = { name: 'Produit', base_unit: unit, user: user }
          attrs[:unit_weight_kg] = 0.060 if unit == 'piece'
          product = build(:product, **attrs)
          expect(product).to be_valid
        end
      end

      it 'est invalide avec base_unit invalide' do
        product = build(:product, name: 'Produit', base_unit: 'g', user: user)
        expect(product).not_to be_valid
        expect(product.errors[:base_unit]).to be_present
      end
    end

    context 'avg_price_per_kg' do
      it 'est valide avec avg_price_per_kg >= 0' do
        product = build(:product, name: 'Farine T55', avg_price_per_kg: 0, user: user)
        expect(product).to be_valid
      end

      it 'est invalide avec avg_price_per_kg négatif' do
        product = build(:product, name: 'Farine T55', avg_price_per_kg: -1, user: user)
        expect(product).not_to be_valid
        expect(product.errors[:avg_price_per_kg]).to be_present
      end
    end
  end

  describe 'règle D6 (unit_weight_kg)' do
    it 'base_unit piece + unit_weight_kg présent et > 0 → valide' do
      product = build(:product, :piece, user: user)
      expect(product).to be_valid
    end

    it 'base_unit piece + unit_weight_kg nil → invalide' do
      product = build(:product, name: 'Oeuf', base_unit: 'piece', unit_weight_kg: nil, user: user)
      expect(product).not_to be_valid
      expect(product.errors[:unit_weight_kg]).to be_present
    end

    it 'base_unit piece + unit_weight_kg = 0 → invalide' do
      product = build(:product, name: 'Oeuf', base_unit: 'piece', unit_weight_kg: 0, user: user)
      expect(product).not_to be_valid
      expect(product.errors[:unit_weight_kg]).to be_present
    end

    it 'base_unit kg + unit_weight_kg nil → valide' do
      product = build(:product, name: 'Farine T55', base_unit: 'kg', unit_weight_kg: nil, user: user)
      expect(product).to be_valid
    end

    it 'base_unit kg + unit_weight_kg présent → invalide' do
      product = build(:product, name: 'Farine T55', base_unit: 'kg', unit_weight_kg: 0.5, user: user)
      expect(product).not_to be_valid
      expect(product.errors[:unit_weight_kg]).to be_present
    end

    it 'base_unit l + unit_weight_kg nil → valide' do
      product = build(:product, :liquid, user: user)
      expect(product).to be_valid
    end
  end

  describe 'méthodes' do
    describe '#piece_unit?' do
      it 'retourne true si base_unit == piece' do
        product = build(:product, :piece, user: user)
        expect(product.piece_unit?).to be(true)
      end

      it 'retourne false sinon' do
        product = build(:product, base_unit: 'kg', user: user)
        expect(product.piece_unit?).to be(false)
      end
    end

    describe '#used_in_recipes?' do
      it 'retourne true si recipe_components existent' do
        product = create(:product, name: 'Farine T55', user: user)
        recipe = create(:recipe, name: 'Pâte brisée', user: user)
        create(:recipe_component, parent_recipe: recipe, component: product)
        expect(product.used_in_recipes?).to be(true)
      end

      it 'retourne false sans recipe_components' do
        product = create(:product, name: 'Farine T55', user: user)
        expect(product.used_in_recipes?).to be(false)
      end
    end

    describe '#simple_avg_price_per_kg' do
      it 'retourne la moyenne simple des price_per_kg des achats actifs' do
        product = create(:product, name: 'Farine T55', user: user)
        supplier = create(:supplier, user: user)
        # price_per_kg = package_price / package_quantity (unit: kg)
        create(:product_purchase, product: product, supplier: supplier, package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier, package_quantity: 1, package_price: 4.0, package_unit: 'kg')
        expect(product.simple_avg_price_per_kg).to eq(3.0)
      end

      it 'ignore les achats inactifs' do
        product = create(:product, name: 'Farine T55', user: user)
        supplier = create(:supplier, user: user)
        create(:product_purchase, product: product, supplier: supplier, package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, :inactive, product: product, supplier: supplier, package_quantity: 1, package_price: 10.0, package_unit: 'kg')
        expect(product.simple_avg_price_per_kg).to eq(2.0)
      end

      it 'retourne 0 sans achats actifs' do
        product = create(:product, name: 'Farine T55', user: user)
        expect(product.simple_avg_price_per_kg).to eq(0)
      end

      it 'arrondit à 2 décimales' do
        product = create(:product, name: 'Farine T55', user: user)
        supplier = create(:supplier, user: user)
        create(:product_purchase, product: product, supplier: supplier, package_quantity: 3, package_price: 10.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier, package_quantity: 7, package_price: 10.0, package_unit: 'kg')
        # price_per_kg values: 10/3 = 3.3333... and 10/7 = 1.4285...
        # simple avg = (3.3333 + 1.4285) / 2 = 2.3809... → 2.38
        expect(product.simple_avg_price_per_kg).to eq(2.38)
      end
    end

    describe '#recipes_count' do
      it 'retourne le bon nombre' do
        product = create(:product, name: 'Farine T55', user: user)
        recipe1 = create(:recipe, name: 'Pâte brisée', user: user)
        recipe2 = create(:recipe, name: 'Pâte sablée', user: user)
        create(:recipe_component, parent_recipe: recipe1, component: product)
        create(:recipe_component, parent_recipe: recipe2, component: product)
        expect(product.recipes_count).to eq(2)
      end
    end
  end

  describe '#high_variability?' do
    let(:supplier) { create(:supplier, user: user) }

    it 'retourne true quand le CV dépasse le seuil' do
      user.update!(price_variability_threshold: 10.0)
      product = create(:product, name: 'Beurre', user: user)
      # prix/kg = 2.0 et 10.0 → CV = 66.67% > 10%
      create(:product_purchase, product: product, supplier: supplier,
             package_quantity: 1, package_price: 2.0, package_unit: 'kg')
      create(:product_purchase, product: product, supplier: supplier,
             package_quantity: 1, package_price: 10.0, package_unit: 'kg')
      expect(product.high_variability?).to be(true)
    end

    it 'retourne false quand le CV est sous le seuil' do
      user.update!(price_variability_threshold: 100.0)
      product = create(:product, name: 'Farine', user: user)
      create(:product_purchase, product: product, supplier: supplier,
             package_quantity: 1, package_price: 5.0, package_unit: 'kg')
      create(:product_purchase, product: product, supplier: supplier,
             package_quantity: 1, package_price: 5.5, package_unit: 'kg')
      expect(product.high_variability?).to be(false)
    end

    it 'retourne false quand le CV est nil (< 2 achats)' do
      product = create(:product, name: 'Sel', user: user)
      expect(product.high_variability?).to be(false)
    end
  end

  describe 'defaults (after_initialize)' do
    it 'base_unit par défaut kg' do
      product = Product.new
      expect(product.base_unit).to eq('kg')
    end

    it 'avg_price_per_kg par défaut 0' do
      product = Product.new
      expect(product.avg_price_per_kg).to eq(0)
    end
  end
end

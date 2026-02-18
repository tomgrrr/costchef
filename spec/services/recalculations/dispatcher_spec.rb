# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recalculations::Dispatcher do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user) }

  describe '.product_purchase_changed' do
    let(:product) { create(:product, user: user) }
    let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 0) }

    before do
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 2.0)
    end

    context 'with a persisted purchase' do
      let!(:purchase) do
        create(:product_purchase, :uncalculated, product: product, supplier: supplier,
                                                 package_unit: 'kg', package_quantity: 10, package_price: 20.0)
      end

      it 'recalculates the full chain: purchase → product → recipe' do
        # Le controller est responsable de calculer et sauvegarder l'achat avant le Dispatcher
        ProductPurchases::PricePerKgCalculator.call(purchase)
        purchase.save!

        described_class.product_purchase_changed(purchase)

        purchase.reload
        expect(purchase.price_per_kg.to_f).to eq(2.0)

        product.reload
        expect(product.avg_price_per_kg.to_f).to eq(2.0)

        recipe.reload
        expect(recipe.cached_total_cost.to_f).to eq(4.0)
        expect(recipe.cached_cost_per_kg.to_f).to eq(2.0)
      end
    end

    context 'with explicit product: (post-destroy)' do
      it 'recalculates product avg to 0 when no purchases remain' do
        product.update_columns(avg_price_per_kg: 5.0)

        described_class.product_purchase_changed(nil, product: product)

        product.reload
        expect(product.avg_price_per_kg.to_f).to eq(0.0)

        recipe.reload
        expect(recipe.cached_total_cost.to_f).to eq(0.0)
      end
    end
  end

  describe '.recipe_component_changed' do
    let(:product) { create(:product, user: user, avg_price_per_kg: 4.0) }

    context 'simple recipe' do
      let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 0) }

      before do
        create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)
      end

      it 'recalculates the recipe' do
        described_class.recipe_component_changed(recipe)
        recipe.reload

        expect(recipe.cached_total_cost.to_f).to eq(4.0)
        expect(recipe.cached_cost_per_kg.to_f).to eq(4.0)
      end
    end

    context 'sub-recipe propagates to parent' do
      let(:subrecipe) { create(:recipe, :subrecipe, user: user, cooking_loss_percentage: 0) }
      let(:parent_recipe) { create(:recipe, user: user, name: 'Tarte', cooking_loss_percentage: 0) }

      before do
        create(:recipe_component, parent_recipe: subrecipe, component: product, quantity_kg: 1.0)
        create(:recipe_component, parent_recipe: parent_recipe, component: subrecipe, quantity_kg: 0.5)
      end

      it 'recalculates the sub-recipe and propagates to parent' do
        described_class.recipe_component_changed(subrecipe)
        subrecipe.reload
        parent_recipe.reload

        expect(subrecipe.cached_cost_per_kg.to_f).to eq(4.0)
        # parent: 0.5 * 4.0 = 2.0
        expect(parent_recipe.cached_total_cost.to_f).to eq(2.0)
      end
    end
  end

  describe '.recipe_changed' do
    let(:product) { create(:product, user: user, avg_price_per_kg: 10.0) }
    let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 0) }

    before do
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)
      Recipes::Recalculator.call(recipe)
    end

    it 'recalculates after cooking_loss_percentage change' do
      recipe.update_columns(cooking_loss_percentage: 20)

      described_class.recipe_changed(recipe)
      recipe.reload

      # total_weight = 1.0 * 0.8 = 0.8
      expect(recipe.cached_total_weight.to_f).to eq(0.8)
      # cost_per_kg = 10.0 / 0.8 = 12.5
      expect(recipe.cached_cost_per_kg.to_f).to eq(12.5)
    end

    context 'propagates to parents when sub-recipe' do
      let(:subrecipe) { create(:recipe, :subrecipe, user: user, cooking_loss_percentage: 0) }
      let(:parent_recipe) { create(:recipe, user: user, name: 'Tarte', cooking_loss_percentage: 0) }

      before do
        create(:recipe_component, parent_recipe: subrecipe, component: product, quantity_kg: 1.0)
        create(:recipe_component, parent_recipe: parent_recipe, component: subrecipe, quantity_kg: 1.0)
        Recipes::Recalculator.call(subrecipe)
        Recipes::Recalculator.call(parent_recipe)
      end

      it 'recalculates parent when sub-recipe changes' do
        subrecipe.update_columns(cooking_loss_percentage: 50)

        described_class.recipe_changed(subrecipe)
        subrecipe.reload
        parent_recipe.reload

        # subrecipe: cost=10, weight=0.5 → cost_per_kg=20
        expect(subrecipe.cached_cost_per_kg.to_f).to eq(20.0)
        # parent: 1.0 * 20.0 = 20.0
        expect(parent_recipe.cached_total_cost.to_f).to eq(20.0)
      end
    end
  end

  describe '.supplier_force_destroyed' do
    it 'recalculates each affected product and its recipes' do
      product_a = create(:product, user: user, name: 'Produit A')
      product_b = create(:product, user: user, name: 'Produit B')

      create(:product_purchase, product: product_a, supplier: supplier,
                                package_quantity_kg: 10.0, price_per_kg: 2.0)
      create(:product_purchase, product: product_b, supplier: supplier,
                                package_quantity_kg: 5.0, price_per_kg: 4.0)

      recipe = create(:recipe, user: user, cooking_loss_percentage: 0)
      create(:recipe_component, parent_recipe: recipe, component: product_a, quantity_kg: 1.0)

      # Pre-calculate
      Products::AvgPriceRecalculator.call(product_a)
      Products::AvgPriceRecalculator.call(product_b)
      Recipes::Recalculator.call(recipe)

      expect(recipe.reload.cached_total_cost.to_f).to eq(2.0)

      # Simulate supplier destruction: delete purchases
      ProductPurchase.where(supplier: supplier).delete_all

      described_class.supplier_force_destroyed([product_a.id, product_b.id])

      expect(product_a.reload.avg_price_per_kg.to_f).to eq(0.0)
      expect(product_b.reload.avg_price_per_kg.to_f).to eq(0.0)
      expect(recipe.reload.cached_total_cost.to_f).to eq(0.0)
    end
  end
end

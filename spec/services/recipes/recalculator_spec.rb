# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::Recalculator do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user) }

  describe '.call' do
    context 'with product components only' do
      let(:product_a) { create(:product, user: user, name: 'Farine', avg_price_per_kg: 2.0) }
      let(:product_b) { create(:product, user: user, name: 'Beurre', avg_price_per_kg: 10.0) }
      let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 0) }

      before do
        create(:recipe_component, parent_recipe: recipe, component: product_a, quantity_kg: 1.0)
        create(:recipe_component, parent_recipe: recipe, component: product_b, quantity_kg: 0.5)
      end

      it 'calculates all 4 cached fields' do
        described_class.call(recipe)
        recipe.reload

        # total_cost = (1.0 * 2.0) + (0.5 * 10.0) = 7.0
        expect(recipe.cached_total_cost.to_f).to eq(7.0)
        # raw_weight = 1.0 + 0.5 = 1.5
        expect(recipe.cached_raw_weight.to_f).to eq(1.5)
        # total_weight = 1.5 (0% loss)
        expect(recipe.cached_total_weight.to_f).to eq(1.5)
        # cost_per_kg = 7.0 / 1.5 = 4.6667
        expect(recipe.cached_cost_per_kg.to_f).to be_within(0.01).of(4.67)
      end
    end

    context 'with a sub-recipe component' do
      let(:product) { create(:product, user: user, name: 'Sucre', avg_price_per_kg: 1.5) }
      let(:subrecipe) do
        create(:recipe, :subrecipe, user: user, cached_cost_per_kg: 8.0)
      end
      let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 0) }

      before do
        create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0.5)
        create(:recipe_component, parent_recipe: recipe, component: subrecipe, quantity_kg: 0.2)
      end

      it 'uses cached_cost_per_kg of the sub-recipe' do
        described_class.call(recipe)
        recipe.reload

        # total_cost = (0.5 * 1.5) + (0.2 * 8.0) = 0.75 + 1.6 = 2.35
        expect(recipe.cached_total_cost.to_f).to eq(2.35)
        expect(recipe.cached_raw_weight.to_f).to eq(0.7)
      end
    end

    context 'with empty recipe (0 components)' do
      let(:recipe) { create(:recipe, user: user) }

      it 'sets all cached fields to 0' do
        described_class.call(recipe)
        recipe.reload

        expect(recipe.cached_total_cost.to_f).to eq(0)
        expect(recipe.cached_raw_weight.to_f).to eq(0)
        expect(recipe.cached_total_weight.to_f).to eq(0)
        expect(recipe.cached_cost_per_kg.to_f).to eq(0)
      end
    end

    context 'with cooking_loss_percentage' do
      let(:product) { create(:product, user: user, avg_price_per_kg: 5.0) }
      let(:recipe) { create(:recipe, user: user, cooking_loss_percentage: 10) }

      before do
        create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)
      end

      it 'applies cooking loss to total_weight' do
        described_class.call(recipe)
        recipe.reload

        expect(recipe.cached_raw_weight.to_f).to eq(1.0)
        # total_weight = 1.0 * (1 - 10/100) = 0.9
        expect(recipe.cached_total_weight.to_f).to eq(0.9)
        # cost_per_kg = 5.0 / 0.9 = 5.5556
        expect(recipe.cached_cost_per_kg.to_f).to be_within(0.01).of(5.56)
      end
    end

    context 'with cooking_loss_percentage nil' do
      let(:product) { create(:product, user: user, avg_price_per_kg: 5.0) }
      let(:recipe) { create(:recipe, user: user) }

      before do
        recipe.update_columns(cooking_loss_percentage: nil)
        create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)
      end

      it 'treats nil as 0% loss' do
        described_class.call(recipe)
        recipe.reload

        expect(recipe.cached_total_weight.to_f).to eq(1.0)
        expect(recipe.cached_cost_per_kg.to_f).to eq(5.0)
      end
    end

    it 'persists via update_columns' do
      product = create(:product, user: user, avg_price_per_kg: 3.0)
      recipe = create(:recipe, user: user, cooking_loss_percentage: 0)
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 2.0)

      described_class.call(recipe)

      fresh = Recipe.find(recipe.id)
      expect(fresh.cached_total_cost.to_f).to eq(6.0)
    end
  end
end

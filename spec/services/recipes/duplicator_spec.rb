# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::Duplicator do
  let(:user) { create(:user) }
  let(:product) { create(:product, user: user, name: 'Farine', avg_price_per_kg: 2.0) }
  let(:recipe) { create(:recipe, user: user, name: 'Tarte', cooking_loss_percentage: 10) }

  before do
    create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.5, quantity_unit: 'kg')
  end

  describe '.call' do
    subject(:duplicate) { described_class.call(recipe) }

    it 'adds "(copie)" to the recipe name' do
      expect(duplicate.name).to eq('Tarte (copie)')
    end

    it 'copies recipe_components with correct values' do
      expect(duplicate.recipe_components.size).to eq(1)

      comp = duplicate.recipe_components.first
      expect(comp.component).to eq(product)
      expect(comp.quantity_kg).to eq(1.5)
      expect(comp.quantity_unit).to eq('kg')
    end

    it 'does not modify the original recipe' do
      duplicate
      expect(recipe.reload.name).to eq('Tarte')
      expect(recipe.recipe_components.count).to eq(1)
    end

    it 'returns a non-persisted recipe' do
      expect(duplicate).to be_new_record
    end

    it 'returns non-persisted recipe_components' do
      duplicate.recipe_components.each do |rc|
        expect(rc).to be_new_record
      end
    end

    context 'with multiple components' do
      let(:product_b) { create(:product, user: user, name: 'Beurre', avg_price_per_kg: 10.0) }

      before do
        create(:recipe_component, parent_recipe: recipe, component: product_b, quantity_kg: 0.5, quantity_unit: 'kg')
      end

      it 'copies all components' do
        expect(duplicate.recipe_components.size).to eq(2)
      end
    end

    context 'with a sub-recipe component' do
      let(:sub_recipe) { create(:recipe, :subrecipe, user: user, name: 'Base') }

      before do
        create(:recipe_component, parent_recipe: recipe, component: sub_recipe, quantity_kg: 2.0, quantity_unit: 'kg')
      end

      it 'copies the sub-recipe component' do
        sub_comp = duplicate.recipe_components.find { |rc| rc.component_type == 'Recipe' }
        expect(sub_comp).to be_present
        expect(sub_comp.component).to eq(sub_recipe)
        expect(sub_comp.quantity_kg).to eq(2.0)
      end
    end
  end
end

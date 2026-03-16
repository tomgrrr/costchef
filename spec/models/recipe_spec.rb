# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: 'other@test.fr') }
  let(:tray_size) { create(:tray_size, user: user, name: 'S', price: 0.5) }

  describe 'validations' do
    context 'name' do
      it 'valide avec nom présent' do
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).to be_valid
      end

      it 'invalide avec nom vide' do
        recipe = build(:recipe, name: '', user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to be_present
      end

      it 'invalide si doublon même user' do
        create(:recipe, name: 'Pâte brisée', user: user)
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to be_present
      end

      it 'valide si doublon autre user (unicité scoped user_id)' do
        create(:recipe, name: 'Pâte brisée', user: other_user)
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).to be_valid
      end
    end

    context 'description' do
      it 'valide avec description nil' do
        recipe = build(:recipe, description: nil, user: user)
        expect(recipe).to be_valid
      end

      it 'valide avec description de 2000 caractères' do
        recipe = build(:recipe, description: 'a' * 2000, user: user)
        expect(recipe).to be_valid
      end

      it 'invalide avec description de 2001 caractères' do
        recipe = build(:recipe, description: 'a' * 2001, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:description]).to be_present
      end
    end

    context 'cooking_loss_percentage' do
      it 'valide avec 0' do
        recipe = build(:recipe, cooking_loss_percentage: 0, user: user)
        expect(recipe).to be_valid
      end

      it 'valide avec 100' do
        recipe = build(:recipe, cooking_loss_percentage: 100, user: user)
        expect(recipe).to be_valid
      end

      it 'valide avec nil' do
        recipe = build(:recipe, cooking_loss_percentage: nil, user: user)
        expect(recipe).to be_valid
      end

      it 'invalide avec -1' do
        recipe = build(:recipe, cooking_loss_percentage: -1, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:cooking_loss_percentage]).to be_present
      end

      it 'invalide avec 101' do
        recipe = build(:recipe, cooking_loss_percentage: 101, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:cooking_loss_percentage]).to be_present
      end
    end

    context 'tray_size_consistency (D PRD)' do
      it 'invalide si has_tray: true et tray_size_id: nil' do
        recipe = build(:recipe, has_tray: true, tray_size: nil, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:tray_size_id]).to be_present
      end

      it 'valide si has_tray: true et tray_size présent' do
        recipe = build(:recipe, has_tray: true, tray_size: tray_size, user: user)
        expect(recipe).to be_valid
      end

      it 'valide si has_tray: false et tray_size_id: nil' do
        recipe = build(:recipe, has_tray: false, tray_size: nil, user: user)
        expect(recipe).to be_valid
      end
    end

    context 'subrecipe_cannot_have_tray' do
      it 'invalide si sellable_as_component: true et has_tray: true' do
        recipe = build(:recipe, sellable_as_component: true, has_tray: true, tray_size: tray_size, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:has_tray]).to include('Une sous-recette ne peut pas avoir de barquette')
      end

      it 'valide si sellable_as_component: true et has_tray: false' do
        recipe = build(:recipe, sellable_as_component: true, has_tray: false, user: user)
        expect(recipe).to be_valid
      end
    end

    context 'sold_by_unit' do
      it 'valide si sold_by_unit: true et poids > 0' do
        recipe = build(:recipe, :sold_by_unit, user: user)
        expect(recipe).to be_valid
      end

      it 'invalide si sold_by_unit: true et poids nil' do
        recipe = build(:recipe, sold_by_unit: true, unit_reference_weight_kg: nil, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:unit_reference_weight_kg]).to be_present
      end

      it 'invalide si sold_by_unit: true et poids = 0' do
        recipe = build(:recipe, sold_by_unit: true, unit_reference_weight_kg: 0, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:unit_reference_weight_kg]).to be_present
      end

      it 'valide si sold_by_unit: false et poids nil' do
        recipe = build(:recipe, sold_by_unit: false, unit_reference_weight_kg: nil, user: user)
        expect(recipe).to be_valid
      end

      it 'invalide si sous-recette et sold_by_unit: true' do
        recipe = build(:recipe, sellable_as_component: true, sold_by_unit: true, unit_reference_weight_kg: 0.250, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:sold_by_unit]).to be_present
      end
    end

    context 'tray_size_belongs_to_same_user' do
      it 'invalide si tray_size appartient à other_user' do
        other_tray = create(:tray_size, name: 'M', user: other_user)
        recipe = build(:recipe, has_tray: true, tray_size: other_tray, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:tray_size]).to be_present
      end

      it 'valide si tray_size appartient à user' do
        recipe = build(:recipe, has_tray: true, tray_size: tray_size, user: user)
        expect(recipe).to be_valid
      end
    end
  end

  describe 'defaults (after_initialize)' do
    it 'cooking_loss_percentage vaut 0 par défaut' do
      recipe = Recipe.new
      expect(recipe.cooking_loss_percentage).to eq(0)
    end

    it 'sellable_as_component vaut false par défaut' do
      recipe = Recipe.new
      expect(recipe.sellable_as_component).to be(false)
    end

    it 'has_tray vaut false par défaut' do
      recipe = Recipe.new
      expect(recipe.has_tray).to be(false)
    end

    it 'sold_by_unit vaut false par défaut' do
      recipe = Recipe.new
      expect(recipe.sold_by_unit).to be(false)
    end
  end

  describe 'scopes' do
    describe '.usable_as_subrecipe' do
      it 'retourne uniquement les recettes avec sellable_as_component: true' do
        sellable = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
        create(:recipe, name: 'Pâte brisée', sellable_as_component: false, user: user)

        expect(user.recipes.usable_as_subrecipe).to eq([sellable])
      end

      it 'ne retourne pas les recettes avec sellable_as_component: false' do
        create(:recipe, name: 'Pâte brisée', sellable_as_component: false, user: user)

        expect(user.recipes.usable_as_subrecipe).to be_empty
      end
    end

    describe '.by_cost_per_kg' do
      it 'retourne les recettes triées par cached_cost_per_kg croissant' do
        expensive = create(:recipe, name: 'Foie gras', cached_cost_per_kg: 50, user: user)
        cheap = create(:recipe, name: 'Pâte brisée', cached_cost_per_kg: 5, user: user)
        mid = create(:recipe, name: 'Crème brûlée', cached_cost_per_kg: 20, user: user)

        expect(user.recipes.by_cost_per_kg).to eq([cheap, mid, expensive])
      end
    end
  end

  describe '#subrecipe?' do
    it 'retourne true si sellable_as_component: true' do
      recipe = build(:recipe, sellable_as_component: true, user: user)
      expect(recipe.subrecipe?).to be(true)
    end

    it 'retourne false si sellable_as_component: false' do
      recipe = build(:recipe, sellable_as_component: false, user: user)
      expect(recipe.subrecipe?).to be(false)
    end
  end

  describe '#used_as_subrecipe?' do
    it 'retourne true si la recette est utilisée comme composant dans une autre recette' do
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
      parent = create(:recipe, name: 'Mille-feuille', user: user)
      create(:recipe_component, parent_recipe: parent, component: subrecipe)

      expect(subrecipe.used_as_subrecipe?).to be(true)
    end

    it 'retourne false sinon' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      expect(recipe.used_as_subrecipe?).to be(false)
    end
  end

  describe '#has_subrecipes?' do
    it 'retourne true si recipe_components contient au moins un component_type Recipe' do
      recipe = create(:recipe, name: 'Mille-feuille', user: user)
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
      create(:recipe_component, parent_recipe: recipe, component: subrecipe)

      expect(recipe.has_subrecipes?).to be(true)
    end

    it 'retourne false sinon' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      product = create(:product, name: 'Farine T55', user: user)
      create(:recipe_component, parent_recipe: recipe, component: product)

      expect(recipe.has_subrecipes?).to be(false)
    end
  end

  describe '#suggested_selling_price' do
    context 'sans barquette' do
      it 'retourne cached_cost_per_kg * markup_coefficient' do
        user_markup = create(:user, email: 'markup@test.fr', markup_coefficient: 2.5)
        recipe = build(:recipe, cached_cost_per_kg: 10, has_tray: false, user: user_markup)

        expect(recipe.suggested_selling_price).to eq(25.0)
      end
    end

    context 'avec barquette' do
      it 'retourne (cached_cost_per_kg * markup_coefficient) + tray_size.price' do
        user_markup = create(:user, email: 'markup2@test.fr', markup_coefficient: 2.0)
        tray = create(:tray_size, name: 'L', price: 0.50, user: user_markup)
        recipe = build(:recipe, cached_cost_per_kg: 10, has_tray: true, tray_size: tray, user: user_markup)

        expect(recipe.suggested_selling_price).to eq(20.50)
      end
    end

    context 'cas nil' do
      it 'retourne nil si cached_cost_per_kg est nil' do
        recipe = build(:recipe, cached_cost_per_kg: nil, user: user)
        expect(recipe.suggested_selling_price).to be_nil
      end

      it 'retourne nil si user.markup_coefficient est nil' do
        user_no_markup = build(:user, email: 'nomark@test.fr', markup_coefficient: nil)
        recipe = build(:recipe, cached_cost_per_kg: 10, user: user_no_markup)
        expect(recipe.suggested_selling_price).to be_nil
      end
    end
  end

  describe '#demotion_alert_message' do
    it 'retourne le message quand sellable_as_component passe de true→false avec des parents' do
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
      parent = create(:recipe, name: 'Mille-feuille', user: user)
      create(:recipe_component, parent_recipe: parent, component: subrecipe)

      subrecipe.update!(sellable_as_component: false)

      expect(subrecipe.demotion_alert_message).to include('1 recette(s) parente(s)')
    end

    it 'retourne nil si pas de parent_recipe_components' do
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)

      subrecipe.update!(sellable_as_component: false)

      expect(subrecipe.demotion_alert_message).to be_nil
    end

    it 'retourne nil si sellable_as_component ne change pas' do
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
      parent = create(:recipe, name: 'Mille-feuille', user: user)
      create(:recipe_component, parent_recipe: parent, component: subrecipe)

      subrecipe.update!(name: 'Crème anglaise')

      expect(subrecipe.demotion_alert_message).to be_nil
    end

    it 'retourne nil si le changement est false→true (promotion)' do
      recipe = create(:recipe, name: 'Pâte brisée', sellable_as_component: false, user: user)

      recipe.update!(sellable_as_component: true)

      expect(recipe.demotion_alert_message).to be_nil
    end

    it 'inclut le bon count avec plusieurs parents' do
      subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
      create(:recipe_component, parent_recipe: create(:recipe, name: 'Mille-feuille', user: user), component: subrecipe)
      create(:recipe_component, parent_recipe: create(:recipe, name: 'Paris-Brest', user: user), component: subrecipe)
      create(:recipe_component, parent_recipe: create(:recipe, name: 'Éclair', user: user), component: subrecipe)

      subrecipe.update!(sellable_as_component: false)

      expect(subrecipe.demotion_alert_message).to include('3 recette(s) parente(s)')
    end
  end

  describe '#unit_cost' do
    it 'retourne cached_cost_per_kg * unit_reference_weight_kg' do
      recipe = build(:recipe, :sold_by_unit, cached_cost_per_kg: 20, user: user)
      expect(recipe.unit_cost).to eq(5.0) # 20 * 0.250
    end

    it 'retourne nil si sold_by_unit est false' do
      recipe = build(:recipe, sold_by_unit: false, cached_cost_per_kg: 20, user: user)
      expect(recipe.unit_cost).to be_nil
    end

    it 'retourne nil si cached_cost_per_kg est nil' do
      recipe = build(:recipe, :sold_by_unit, cached_cost_per_kg: nil, user: user)
      expect(recipe.unit_cost).to be_nil
    end
  end

  describe '#unit_selling_price' do
    it 'retourne suggested_selling_price * unit_reference_weight_kg' do
      user_markup = create(:user, email: 'markup_unit@test.fr', markup_coefficient: 2.0)
      recipe = build(:recipe, :sold_by_unit, cached_cost_per_kg: 20, user: user_markup)
      # suggested_selling_price = 20 * 2.0 = 40, unit_selling_price = 40 * 0.250 = 10
      expect(recipe.unit_selling_price).to eq(10.0)
    end

    it 'retourne nil si sold_by_unit est false' do
      recipe = build(:recipe, sold_by_unit: false, cached_cost_per_kg: 20, user: user)
      expect(recipe.unit_selling_price).to be_nil
    end

    it 'retourne nil si suggested_selling_price est nil' do
      recipe = build(:recipe, :sold_by_unit, cached_cost_per_kg: nil, user: user)
      expect(recipe.unit_selling_price).to be_nil
    end
  end

  describe '#calculated_raw_weight' do
    it 'retourne la somme des quantity_kg de tous les composants' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      product1 = create(:product, name: 'Farine T55', user: user)
      product2 = create(:product, name: 'Beurre', user: user)
      create(:recipe_component, parent_recipe: recipe, component: product1, quantity_kg: 0.5)
      create(:recipe_component, parent_recipe: recipe, component: product2, quantity_kg: 0.25)

      expect(recipe.calculated_raw_weight).to eq(0.75)
    end

    it 'retourne 0 si aucun composant' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      expect(recipe.calculated_raw_weight).to eq(0)
    end
  end

  describe '#calculated_total_weight' do
    it 'applique cooking_loss_percentage : 1kg à 20% → 0.8kg' do
      recipe = create(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 20, user: user)
      product = create(:product, name: 'Farine T55', user: user)
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)

      expect(recipe.calculated_total_weight).to eq(0.8)
    end

    it 'retourne 0 si raw_weight est 0' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      expect(recipe.calculated_total_weight).to eq(0)
    end

    it 'traite cooking_loss_percentage nil comme 0%' do
      recipe = create(:recipe, name: 'Pâte brisée', cooking_loss_percentage: nil, user: user)
      product = create(:product, name: 'Farine T55', user: user)
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)

      expect(recipe.calculated_total_weight).to eq(1.0)
    end
  end
end

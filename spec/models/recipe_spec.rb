# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  # ============================================
  # 1. VALIDATIONS
  # ============================================

  describe 'validations' do
    context 'nom' do
      it 'est valide avec un nom présent' do
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).to be_valid
      end

      it 'est invalide avec un nom vide' do
        recipe = build(:recipe, name: '', user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to be_present
      end

      it 'est invalide si doublon même user' do
        create(:recipe, name: 'Pâte brisée', user: user)
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to be_present
      end

      it 'est valide si nom dupliqué autre user' do
        create(:recipe, name: 'Pâte brisée', user: other_user)
        recipe = build(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe).to be_valid
      end
    end

    context 'description' do
      it 'est valide avec description nil' do
        recipe = build(:recipe, name: 'Pâte brisée', description: nil, user: user)
        expect(recipe).to be_valid
      end

      it 'est valide avec description 2000 caractères' do
        recipe = build(:recipe, name: 'Pâte brisée', description: 'a' * 2000, user: user)
        expect(recipe).to be_valid
      end

      it 'est invalide avec description 2001 caractères' do
        recipe = build(:recipe, name: 'Pâte brisée', description: 'a' * 2001, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:description]).to be_present
      end
    end

    context 'cooking_loss_percentage' do
      it 'est valide avec 0' do
        recipe = build(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 0, user: user)
        expect(recipe).to be_valid
      end

      it 'est valide avec 100' do
        recipe = build(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 100, user: user)
        expect(recipe).to be_valid
      end

      it 'est valide avec nil' do
        recipe = build(:recipe, name: 'Pâte brisée', cooking_loss_percentage: nil, user: user)
        expect(recipe).to be_valid
      end

      it 'est invalide avec -1' do
        recipe = build(:recipe, name: 'Pâte brisée', cooking_loss_percentage: -1, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:cooking_loss_percentage]).to be_present
      end

      it 'est invalide avec 101' do
        recipe = build(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 101, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:cooking_loss_percentage]).to be_present
      end
    end

    context 'tray_size_consistency' do
      it 'est invalide si has_tray=true et tray_size_id=nil' do
        recipe = build(:recipe, name: 'Pâte brisée', has_tray: true, tray_size: nil, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:tray_size_id]).to be_present
      end

      it 'est valide si has_tray=true et tray_size_id présent' do
        tray = create(:tray_size, user: user)
        recipe = build(:recipe, name: 'Pâte brisée', has_tray: true, tray_size: tray, user: user)
        expect(recipe).to be_valid
      end

      it 'est valide si has_tray=false et tray_size_id=nil' do
        recipe = build(:recipe, name: 'Pâte brisée', has_tray: false, tray_size: nil, user: user)
        expect(recipe).to be_valid
      end
    end

    context 'tray_size_belongs_to_same_user' do
      it 'est invalide si tray_size appartient à un autre user' do
        other_tray = create(:tray_size, name: 'Barquette autre', user: other_user)
        recipe = build(:recipe, name: 'Pâte brisée', has_tray: true, tray_size: other_tray, user: user)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:tray_size]).to be_present
      end

      it 'est valide si tray_size appartient au même user' do
        tray = create(:tray_size, user: user)
        recipe = build(:recipe, name: 'Pâte brisée', has_tray: true, tray_size: tray, user: user)
        expect(recipe).to be_valid
      end
    end
  end

  # ============================================
  # 2. DEFAULTS (after_initialize)
  # ============================================

  describe 'defaults (after_initialize)' do
    it 'cooking_loss_percentage par défaut 0' do
      recipe = Recipe.new
      expect(recipe.cooking_loss_percentage).to eq(0)
    end

    it 'sellable_as_component par défaut false' do
      recipe = Recipe.new
      expect(recipe.sellable_as_component).to be(false)
    end

    it 'has_tray par défaut false' do
      recipe = Recipe.new
      expect(recipe.has_tray).to be(false)
    end
  end

  # ============================================
  # 3. SCOPES
  # ============================================

  describe 'scopes' do
    describe '.usable_as_subrecipe' do
      it 'retourne uniquement les recettes avec sellable_as_component=true' do
        sellable = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
        create(:recipe, name: 'Pâte brisée', sellable_as_component: false, user: user)

        expect(user.recipes.usable_as_subrecipe).to eq([sellable])
      end

      it 'exclut les recettes avec sellable_as_component=false' do
        create(:recipe, name: 'Pâte brisée', sellable_as_component: false, user: user)

        expect(user.recipes.usable_as_subrecipe).to be_empty
      end
    end
  end

  # ============================================
  # 4. MÉTHODES MÉTIER
  # ============================================

  describe 'méthodes métier' do
    describe '#used_as_subrecipe?' do
      it 'retourne true si utilisée comme composant dans une autre recette' do
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

    describe '#parent_recipes_count' do
      it 'retourne le bon nombre de recettes parentes' do
        subrecipe = create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user)
        parent1 = create(:recipe, name: 'Mille-feuille', user: user)
        parent2 = create(:recipe, name: 'Éclair', user: user)
        create(:recipe_component, parent_recipe: parent1, component: subrecipe)
        create(:recipe_component, parent_recipe: parent2, component: subrecipe)

        expect(subrecipe.parent_recipes_count).to eq(2)
      end
    end

    describe '#suggested_selling_price' do
      it 'retourne nil si cached_cost_per_kg est nil' do
        recipe = build(:recipe, cached_cost_per_kg: nil, user: user)
        expect(recipe.suggested_selling_price).to be_nil
      end

      it 'retourne nil si user.markup_coefficient est nil' do
        user_no_markup = build(:user, email: 'nomark@test.fr', markup_coefficient: nil)
        recipe = build(:recipe, cached_cost_per_kg: 10, user: user_no_markup)
        expect(recipe.suggested_selling_price).to be_nil
      end

      it 'retourne cached_cost_per_kg * markup_coefficient si has_tray=false' do
        user_with_markup = create(:user, email: 'markup@test.fr', markup_coefficient: 2.5)
        recipe = build(:recipe, cached_cost_per_kg: 10, has_tray: false, user: user_with_markup)
        expect(recipe.suggested_selling_price).to eq(25.0)
      end

      it 'retourne (cached_cost_per_kg * markup_coefficient) + tray_size.price si has_tray=true' do
        user_with_markup = create(:user, email: 'markup2@test.fr', markup_coefficient: 2.0)
        tray = create(:tray_size, price: 0.50, user: user_with_markup)
        recipe = build(:recipe, cached_cost_per_kg: 10, has_tray: true, tray_size: tray, user: user_with_markup)
        expect(recipe.suggested_selling_price).to eq(20.50)
      end

      it 'retourne base_price sans ajout barquette si has_tray=true mais tray_size=nil' do
        user_with_markup = create(:user, email: 'markup3@test.fr', markup_coefficient: 2.0)
        recipe = build(:recipe, cached_cost_per_kg: 10, has_tray: true, tray_size: nil, user: user_with_markup)
        # Bypasse la validation tray_size_consistency pour tester le comportement de la méthode
        recipe.define_singleton_method(:tray_size_consistency) { nil }
        # Sans tray_size, tray_size&.price est nil → branche else → base_price seul
        expect(recipe.suggested_selling_price).to eq(20.0)
      end
    end
  end

  # ============================================
  # 5. MÉTHODES DE CALCUL
  # ============================================

  describe 'méthodes de calcul' do
    describe '#calculated_raw_weight' do
      it 'retourne 0 si aucun composant' do
        recipe = create(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe.calculated_raw_weight).to eq(0)
      end

      it 'retourne la somme des quantity_kg des composants' do
        recipe = create(:recipe, name: 'Pâte brisée', user: user)
        product1 = create(:product, name: 'Farine T55', user: user)
        product2 = create(:product, name: 'Beurre', user: user)
        create(:recipe_component, parent_recipe: recipe, component: product1, quantity_kg: 0.5)
        create(:recipe_component, parent_recipe: recipe, component: product2, quantity_kg: 0.25)

        expect(recipe.calculated_raw_weight).to eq(0.75)
      end
    end

    describe '#calculated_total_weight' do
      it 'retourne 0 si aucun composant' do
        recipe = create(:recipe, name: 'Pâte brisée', user: user)
        expect(recipe.calculated_total_weight).to eq(0)
      end

      it 'applique la perte cuisson : raw_weight * (1 - cooking_loss_percentage/100)' do
        recipe = create(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 20, user: user)
        product = create(:product, name: 'Farine T55', user: user)
        create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 1.0)

        expect(recipe.calculated_total_weight).to eq(0.8)
      end
    end
  end
end

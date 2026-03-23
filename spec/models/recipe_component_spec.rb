# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeComponent, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: 'other@test.fr') }
  let(:product) { create(:product, user: user, avg_price_per_kg: 4.0) }
  let(:recipe) { create(:recipe, user: user) }
  let(:subrecipe) { create(:recipe, :subrecipe, user: user, cached_cost_per_kg: 8.0) }

  # ============================================
  # 1. VALIDATIONS DE BASE
  # ============================================

  describe 'validations' do
    context 'quantity_kg' do
      it 'valide avec quantity_kg > 0' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0.5)
        expect(rc).to be_valid
      end

      it 'invalide avec quantity_kg = 0' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0)
        expect(rc).not_to be_valid
        expect(rc.errors[:quantity_kg]).to be_present
      end

      it 'invalide avec quantity_kg négatif' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: -1)
        expect(rc).not_to be_valid
        expect(rc.errors[:quantity_kg]).to be_present
      end

      it 'invalide avec quantity_kg nil' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: nil)
        expect(rc).not_to be_valid
        expect(rc.errors[:quantity_kg]).to be_present
      end
    end

    context 'quantity_unit' do
      Units::VALID_UNITS.each do |unit|
        it "valide avec quantity_unit #{unit}" do
          rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_unit: unit)
          expect(rc).to be_valid
        end
      end

      it 'invalide avec une unité inconnue' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_unit: 'box')
        expect(rc).not_to be_valid
        expect(rc.errors[:quantity_unit]).to be_present
      end

      it 'invalide avec nil' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_unit: nil)
        expect(rc).not_to be_valid
        expect(rc.errors[:quantity_unit]).to be_present
      end
    end

    context 'component_type' do
      it 'valide avec Product' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product)
        expect(rc).to be_valid
      end

      it 'valide avec Recipe' do
        rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
        expect(rc).to be_valid
      end

      it 'invalide avec une valeur inconnue' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product)
        rc.component_type = 'Ingredient'
        # Polymorphic belongs_to tente de résoudre la constante 'Ingredient'
        # ce qui lève NameError — le composant invalide ne peut pas être sauvegardé
        expect { rc.valid? }.to raise_error(NameError)
      end

      it 'invalide avec nil' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product)
        rc.component_type = nil
        expect(rc).not_to be_valid
        expect(rc.errors[:component_type]).to be_present
      end
    end

    context 'unicité (D9 PRD)' do
      it 'invalide si le même product est ajouté deux fois à la même recette' do
        create(:recipe_component, parent_recipe: recipe, component: product)
        rc = build(:recipe_component, parent_recipe: recipe, component: product)
        expect(rc).not_to be_valid
        expect(rc.errors[:component_id]).to be_present
      end

      it 'valide si le même product est dans deux recettes différentes' do
        other_recipe = create(:recipe, name: 'Pâte sablée', user: user)
        create(:recipe_component, parent_recipe: recipe, component: product)
        rc = build(:recipe_component, parent_recipe: other_recipe, component: product)
        expect(rc).to be_valid
      end

      it 'invalide si la même sous-recette est ajoutée deux fois à la même recette' do
        create(:recipe_component, parent_recipe: recipe, component: subrecipe)
        rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
        expect(rc).not_to be_valid
        expect(rc.errors[:component_id]).to be_present
      end
    end
  end

  # ============================================
  # 2. VALIDATIONS MÉTIER AVANCÉES
  # ============================================

  describe 'validate_subrecipe_is_sellable' do
    it 'invalide si component est une Recipe avec sellable_as_component: false' do
      non_sellable = create(:recipe, name: 'Non vendable', sellable_as_component: false, user: user)
      rc = build(:recipe_component, parent_recipe: recipe, component: non_sellable)
      expect(rc).not_to be_valid
      expect(rc.errors[:base]).to be_present
    end

    it 'valide si component est une Recipe avec sellable_as_component: true' do
      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc).to be_valid
    end
  end

  describe 'validate_max_depth (3 niveaux max)' do
    it 'valide : sous-recette contenant uniquement des produits (profondeur 1)' do
      create(:recipe_component, parent_recipe: subrecipe, component: product)

      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc).to be_valid
    end

    it 'valide : sous-recette contenant une sous-recette qui ne contient que des produits (profondeur 2)' do
      level2 = create(:recipe, :subrecipe, name: 'Ganache', user: user)
      create(:recipe_component, parent_recipe: level2, component: product)
      create(:recipe_component, parent_recipe: subrecipe, component: level2)

      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc).to be_valid
    end

    it 'valide : chaîne de 3 sous-recettes imbriquées (profondeur 3)' do
      level2 = create(:recipe, :subrecipe, name: 'Ganache', user: user)
      level3 = create(:recipe, :subrecipe, name: 'Crème', user: user)
      create(:recipe_component, parent_recipe: level3, component: product)
      create(:recipe_component, parent_recipe: level2, component: level3)
      create(:recipe_component, parent_recipe: subrecipe, component: level2)

      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc).to be_valid
    end

    it 'invalide : chaîne de 4 sous-recettes imbriquées (profondeur 4)' do
      level2 = create(:recipe, :subrecipe, name: 'Ganache', user: user)
      level3 = create(:recipe, :subrecipe, name: 'Crème', user: user)
      level4 = create(:recipe, :subrecipe, name: 'Base', user: user)
      create(:recipe_component, parent_recipe: level4, component: product)
      create(:recipe_component, parent_recipe: level3, component: level4)
      create(:recipe_component, parent_recipe: level2, component: level3)
      create(:recipe_component, parent_recipe: subrecipe, component: level2)

      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc).not_to be_valid
      expect(rc.errors[:base].join).to include('3 niveaux max')
    end

    it 'valide : ajout dans une recette déjà à profondeur 2 au-dessus (profondeur totale 3)' do
      # grandparent → parent → middle (2 niveaux au-dessus)
      middle = create(:recipe, :subrecipe, name: 'Middle', user: user)
      parent_r = create(:recipe, :subrecipe, name: 'Parent', user: user)
      grandparent_r = create(:recipe, name: 'GrandParent', user: user)
      create(:recipe_component, parent_recipe: grandparent_r, component: parent_r)
      create(:recipe_component, parent_recipe: parent_r, component: middle)

      new_sub = create(:recipe, :subrecipe, name: 'Nouvelle sous', user: user)
      rc = build(:recipe_component, parent_recipe: middle, component: new_sub)
      expect(rc).to be_valid
    end

    it 'invalide : profondeur totale dépasse 3 (3 au-dessus + 1 en dessous)' do
      # great_grandparent → grandparent → parent → middle (3 niveaux au-dessus)
      middle = create(:recipe, :subrecipe, name: 'Middle', user: user)
      parent_r = create(:recipe, :subrecipe, name: 'Parent', user: user)
      grandparent_r = create(:recipe, :subrecipe, name: 'GrandParent', user: user)
      great_grandparent_r = create(:recipe, name: 'GreatGrandParent', user: user)
      create(:recipe_component, parent_recipe: great_grandparent_r, component: grandparent_r)
      create(:recipe_component, parent_recipe: grandparent_r, component: parent_r)
      create(:recipe_component, parent_recipe: parent_r, component: middle)

      new_sub = create(:recipe, :subrecipe, name: 'Nouvelle sous', user: user)
      rc = build(:recipe_component, parent_recipe: middle, component: new_sub)
      expect(rc).not_to be_valid
      expect(rc.errors[:base].join).to include('profondeur totale')
    end
  end

  describe 'validate_no_self_reference' do
    it 'invalide si une recette se contient elle-même' do
      self_ref = create(:recipe, :subrecipe, name: 'Self', user: user)
      rc = build(:recipe_component, parent_recipe: self_ref, component: self_ref)
      expect(rc).not_to be_valid
      expect(rc.errors[:base].join).to include('elle-même')
    end
  end

  describe 'validate_no_circular_reference' do
    it 'invalide si la sous-recette contient déjà la recette parente comme composant' do
      recipe_a = create(:recipe, :subrecipe, name: 'Recette A', user: user)
      recipe_b = create(:recipe, :subrecipe, name: 'Recette B', user: user)
      create(:recipe_component, parent_recipe: recipe_b, component: recipe_a)

      rc = build(:recipe_component, parent_recipe: recipe_a, component: recipe_b)
      expect(rc).not_to be_valid
      expect(rc.errors[:base].join).to include('circulaire')
    end

    it 'valide dans les autres cas' do
      recipe_a = create(:recipe, :subrecipe, name: 'Recette A', user: user)
      recipe_b = create(:recipe, :subrecipe, name: 'Recette B', user: user)

      rc = build(:recipe_component, parent_recipe: recipe_a, component: recipe_b)
      expect(rc).to be_valid
    end
  end

  describe 'validate_same_user' do
    it 'invalide si le product composant appartient à other_user' do
      other_product = create(:product, name: 'Beurre', user: other_user)
      rc = build(:recipe_component, parent_recipe: recipe, component: other_product)
      expect(rc).not_to be_valid
      expect(rc.errors[:component]).to be_present
    end

    it 'invalide si la recipe composant appartient à other_user' do
      other_subrecipe = create(:recipe, :subrecipe, name: 'Crème other', user: other_user)
      rc = build(:recipe_component, parent_recipe: recipe, component: other_subrecipe)
      expect(rc).not_to be_valid
      expect(rc.errors[:component]).to be_present
    end

    it 'valide si composant appartient au même user' do
      rc = build(:recipe_component, parent_recipe: recipe, component: product)
      expect(rc).to be_valid
    end
  end

  # ============================================
  # 3. MÉTHODES D'INSTANCE
  # ============================================

  describe '#product_component?' do
    it 'retourne true si component_type == Product' do
      rc = build(:recipe_component, parent_recipe: recipe, component: product)
      expect(rc.product_component?).to be(true)
    end

    it 'retourne false si component_type == Recipe' do
      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc.product_component?).to be(false)
    end
  end

  describe '#recipe_component?' do
    it 'retourne true si component_type == Recipe' do
      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe)
      expect(rc.recipe_component?).to be(true)
    end

    it 'retourne false si component_type == Product' do
      rc = build(:recipe_component, parent_recipe: recipe, component: product)
      expect(rc.recipe_component?).to be(false)
    end
  end

  describe '#effective_weight_kg' do
    it 'retourne quantity_kg pour un produit normal' do
      rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0.5)
      expect(rc.effective_weight_kg).to eq(0.5)
    end

    it 'retourne quantity_kg × coefficient pour un produit déshydraté' do
      dehydrated_product = create(:product, name: 'Couscous', base_unit: 'kg',
                                            dehydrated: true, rehydration_coefficient: 3.0, user: user)
      rc = build(:recipe_component, parent_recipe: recipe, component: dehydrated_product, quantity_kg: 0.5)
      expect(rc.effective_weight_kg).to eq(1.5)
    end

    it 'retourne quantity_kg pour un composant sous-recette' do
      rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe, quantity_kg: 0.5)
      expect(rc.effective_weight_kg).to eq(0.5)
    end
  end

  describe '#line_cost' do
    context 'composant Product' do
      it 'retourne quantity_kg * product.avg_price_per_kg' do
        rc = build(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0.5)
        expect(rc.line_cost).to eq(2.0)
      end

      it 'retourne 0 si avg_price_per_kg est 0' do
        zero_product = create(:product, name: 'Eau', user: user, avg_price_per_kg: 0)
        rc = build(:recipe_component, parent_recipe: recipe, component: zero_product, quantity_kg: 1.0)
        expect(rc.line_cost).to eq(0)
      end
    end

    context 'composant Recipe (sous-recette)' do
      it 'retourne quantity_kg * subrecipe.cached_cost_per_kg' do
        rc = build(:recipe_component, parent_recipe: recipe, component: subrecipe, quantity_kg: 0.5)
        expect(rc.line_cost).to eq(4.0)
      end

      it 'retourne 0 si cached_cost_per_kg est 0' do
        zero_subrecipe = create(:recipe, :subrecipe, name: 'Bouillon', user: user, cached_cost_per_kg: 0)
        rc = build(:recipe_component, parent_recipe: recipe, component: zero_subrecipe, quantity_kg: 1.0)
        expect(rc.line_cost).to eq(0)
      end
    end

    context 'cas dégénérés' do
      it 'retourne 0 si component est nil' do
        rc = RecipeComponent.new(quantity_kg: 1.0, component: nil)
        expect(rc.line_cost).to eq(0)
      end

      it 'retourne 0 si quantity_kg est nil' do
        rc = RecipeComponent.new(quantity_kg: nil, component: product)
        expect(rc.line_cost).to eq(0)
      end
    end
  end
end

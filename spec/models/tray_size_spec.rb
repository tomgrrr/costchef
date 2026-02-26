# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TraySize, type: :model do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'associations' do
    it 'belongs_to user' do
      tray_size = build(:tray_size, user: user)
      expect(tray_size.user).to eq(user)
    end

    it 'has_many recipes' do
      tray_size = create(:tray_size, user: user)
      recipe = create(:recipe, name: 'Pâte brisée', user: user, tray_size: tray_size)
      expect(tray_size.recipes).to include(recipe)
    end
  end

  describe 'validations' do
    context 'name' do
      it 'est valide avec un nom présent' do
        tray_size = build(:tray_size, name: 'Barquette 500g', user: user)
        expect(tray_size).to be_valid
      end

      it 'est invalide avec un nom vide' do
        tray_size = build(:tray_size, name: '', user: user)
        expect(tray_size).not_to be_valid
        expect(tray_size.errors[:name]).to be_present
      end

      it 'est invalide si doublon même user' do
        create(:tray_size, name: 'Barquette 500g', user: user)
        tray_size = build(:tray_size, name: 'Barquette 500g', user: user)
        expect(tray_size).not_to be_valid
        expect(tray_size.errors[:name]).to be_present
      end

      it 'est valide si nom dupliqué autre user' do
        create(:tray_size, name: 'Barquette 500g', user: other_user)
        tray_size = build(:tray_size, name: 'Barquette 500g', user: user)
        expect(tray_size).to be_valid
      end
    end

    context 'price' do
      it 'est valide avec price >= 0' do
        tray_size = build(:tray_size, price: 0, user: user)
        expect(tray_size).to be_valid
      end

      it 'est invalide sans price' do
        tray_size = build(:tray_size, price: nil, user: user)
        expect(tray_size).not_to be_valid
        expect(tray_size.errors[:price]).to be_present
      end

      it 'est invalide avec price négatif' do
        tray_size = build(:tray_size, price: -1, user: user)
        expect(tray_size).not_to be_valid
        expect(tray_size.errors[:price]).to be_present
      end
    end
  end

  describe 'callback before_destroy : nullify_recipes_tray_reference' do
    it 'nullifie tray_size_id et has_tray des recettes associées' do
      tray_size = create(:tray_size, user: user)
      recipe = create(:recipe, name: 'Pâte brisée', user: user, tray_size: tray_size, has_tray: true)

      tray_size.destroy!

      recipe.reload
      expect(recipe.tray_size_id).to be_nil
      expect(recipe.has_tray).to be(false)
    end

    it 'se détruit sans erreur sans recettes associées' do
      tray_size = create(:tray_size, user: user)
      expect { tray_size.destroy! }.to change(TraySize, :count).by(-1)
    end
  end

  describe '#recipes_count' do
    it 'retourne 0 sans recettes' do
      tray_size = create(:tray_size, user: user)
      expect(tray_size.recipes_count).to eq(0)
    end

    it 'retourne le bon compte avec recettes associées' do
      tray_size = create(:tray_size, user: user)
      create(:recipe, name: 'Pâte brisée', user: user, tray_size: tray_size)
      create(:recipe, name: 'Pâte sablée', user: user, tray_size: tray_size)
      expect(tray_size.recipes_count).to eq(2)
    end
  end
end

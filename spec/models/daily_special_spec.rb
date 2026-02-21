# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailySpecial, type: :model do
  let(:user) { create(:user, email: 'chef@test.fr') }

  describe 'validations' do
    context 'category' do
      %w[meat fish side].each do |cat|
        it "est valide avec category #{cat}" do
          entry = build(:daily_special, category: cat, user: user)
          expect(entry).to be_valid
        end
      end

      it 'est invalide avec category dessert' do
        entry = build(:daily_special, category: 'dessert', user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:category]).to be_present
      end
    end

    context 'item_name' do
      it 'est invalide sans item_name' do
        entry = build(:daily_special, item_name: nil, user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:item_name]).to be_present
      end
    end

    context 'entry_date' do
      it 'est invalide sans entry_date' do
        entry = build(:daily_special, entry_date: nil, user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:entry_date]).to be_present
      end
    end

    context 'cost_per_kg' do
      it 'est invalide sans cost_per_kg' do
        entry = build(:daily_special, cost_per_kg: nil, user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:cost_per_kg]).to be_present
      end

      it 'est invalide avec cost_per_kg: 0' do
        entry = build(:daily_special, cost_per_kg: 0, user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:cost_per_kg]).to be_present
      end

      it 'est invalide avec cost_per_kg: -1' do
        entry = build(:daily_special, cost_per_kg: -1, user: user)
        expect(entry).not_to be_valid
        expect(entry.errors[:cost_per_kg]).to be_present
      end
    end
  end

  describe 'scopes' do
    let!(:meat_entry) { create(:daily_special, category: 'meat', item_name: 'Bœuf', user: user) }
    let!(:fish_entry) { create(:daily_special, category: 'fish', item_name: 'Saumon', user: user) }
    let!(:side_entry) { create(:daily_special, category: 'side', item_name: 'Riz', user: user) }

    it '.meats retourne uniquement les viandes' do
      expect(user.daily_specials.meats).to contain_exactly(meat_entry)
    end

    it '.fishes retourne uniquement les poissons' do
      expect(user.daily_specials.fishes).to contain_exactly(fish_entry)
    end

    it '.sides retourne uniquement les accompagnements' do
      expect(user.daily_specials.sides).to contain_exactly(side_entry)
    end
  end

  describe 'moyennes' do
    let(:other_user) { create(:user, email: 'other@test.fr') }

    context 'meat_average' do
      it 'retourne 0 sans entrées' do
        expect(user.daily_specials.meat_average).to eq(0)
      end

      it 'retourne le cost_per_kg avec 1 entrée' do
        create(:daily_special, category: 'meat', cost_per_kg: 10.0, user: user)
        expect(user.daily_specials.meat_average).to eq(10.0)
      end

      it 'retourne la moyenne avec 2 entrées' do
        create(:daily_special, category: 'meat', cost_per_kg: 10.0, item_name: 'Bœuf', user: user)
        create(:daily_special, category: 'meat', cost_per_kg: 20.0, item_name: 'Agneau', user: user)
        expect(user.daily_specials.meat_average).to eq(15.0)
      end

      it 'ne mélange pas les catégories' do
        create(:daily_special, category: 'meat', cost_per_kg: 10.0, user: user)
        create(:daily_special, category: 'fish', cost_per_kg: 50.0, item_name: 'Saumon', user: user)
        create(:daily_special, category: 'side', cost_per_kg: 50.0, item_name: 'Riz', user: user)
        expect(user.daily_specials.meat_average).to eq(10.0)
      end

      it 'ne mélange pas les users' do
        create(:daily_special, category: 'meat', cost_per_kg: 10.0, user: user)
        create(:daily_special, category: 'meat', cost_per_kg: 100.0, user: other_user)
        expect(user.daily_specials.meat_average).to eq(10.0)
      end
    end
  end
end

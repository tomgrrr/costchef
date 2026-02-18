# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Units::Converter do
  describe 'Units::VALID_UNITS' do
    it 'contains exactly the 6 supported units' do
      expect(Units::VALID_UNITS).to eq(%w[kg g l cl ml piece])
    end
  end

  describe '.to_kg' do
    it 'returns quantity as-is for kg' do
      expect(described_class.to_kg(2.5, 'kg')).to eq(2.5)
    end

    it 'converts grams to kg' do
      expect(described_class.to_kg(500, 'g')).to eq(0.5)
    end

    it 'treats liters as kg (1L = 1kg)' do
      expect(described_class.to_kg(1, 'l')).to eq(1.0)
    end

    it 'converts centiliters to kg' do
      expect(described_class.to_kg(75, 'cl')).to eq(0.75)
    end

    it 'converts milliliters to kg' do
      expect(described_class.to_kg(500, 'ml')).to eq(0.5)
    end

    context 'with piece unit' do
      it 'multiplies by unit_weight_kg' do
        product = double('Product', unit_weight_kg: 0.06)
        expect(described_class.to_kg(30, 'piece', product: product)).to be_within(0.0001).of(1.8)
      end

      it 'returns 0.0 when product is nil' do
        expect(described_class.to_kg(30, 'piece')).to eq(0.0)
      end

      it 'returns 0.0 when unit_weight_kg is nil' do
        product = double('Product', unit_weight_kg: nil)
        expect(described_class.to_kg(30, 'piece', product: product)).to eq(0.0)
      end

      it 'returns 0.0 when unit_weight_kg is zero' do
        product = double('Product', unit_weight_kg: 0)
        expect(described_class.to_kg(30, 'piece', product: product)).to eq(0.0)
      end
    end

    it 'falls back to kg for unknown units' do
      expect(described_class.to_kg(2, 'box')).to eq(2.0)
    end

    it 'handles uppercase unit strings' do
      expect(described_class.to_kg(500, 'G')).to eq(0.5)
    end
  end

  describe '.to_display_unit' do
    it 'returns quantity_kg as-is for kg' do
      expect(described_class.to_display_unit(2.5, 'kg')).to eq(2.5)
    end

    it 'converts kg to grams' do
      expect(described_class.to_display_unit(0.5, 'g')).to eq(500.0)
    end

    it 'returns quantity_kg as-is for liters (1kg = 1L)' do
      expect(described_class.to_display_unit(1, 'l')).to eq(1.0)
    end

    it 'converts kg to centiliters' do
      expect(described_class.to_display_unit(0.75, 'cl')).to eq(75.0)
    end

    it 'converts kg to milliliters' do
      expect(described_class.to_display_unit(0.5, 'ml')).to eq(500.0)
    end

    context 'with piece unit' do
      it 'divides by unit_weight_kg' do
        product = double('Product', unit_weight_kg: 0.25)
        expect(described_class.to_display_unit(1.0, 'piece', product: product)).to eq(4.0)
      end

      it 'returns quantity_kg when product is nil' do
        expect(described_class.to_display_unit(1.0, 'piece')).to eq(1.0)
      end

      it 'returns quantity_kg when unit_weight_kg is zero' do
        product = double('Product', unit_weight_kg: 0)
        expect(described_class.to_display_unit(1.0, 'piece', product: product)).to eq(1.0)
      end
    end
  end
end

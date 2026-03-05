# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Units do
  describe 'ALLOWED_PURCHASE_UNITS' do
    it 'autorise kg et g pour base_unit kg' do
      expect(Units::ALLOWED_PURCHASE_UNITS['kg']).to eq(%w[kg g])
    end

    it 'autorise l, cl et ml pour base_unit l' do
      expect(Units::ALLOWED_PURCHASE_UNITS['l']).to eq(%w[l cl ml])
    end

    it 'autorise uniquement piece pour base_unit piece' do
      expect(Units::ALLOWED_PURCHASE_UNITS['piece']).to eq(%w[piece])
    end
  end

  describe '.allowed_for' do
    it 'retourne [kg, g] pour kg' do
      expect(Units.allowed_for('kg')).to eq(%w[kg g])
    end

    it 'retourne [l, cl, ml] pour l' do
      expect(Units.allowed_for('l')).to eq(%w[l cl ml])
    end

    it 'retourne [piece] pour piece' do
      expect(Units.allowed_for('piece')).to eq(%w[piece])
    end

    it 'retourne un tableau vide pour un base_unit invalide' do
      expect(Units.allowed_for('tonne')).to eq([])
    end
  end
end

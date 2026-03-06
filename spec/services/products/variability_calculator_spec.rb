# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::VariabilityCalculator do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:supplier) { create(:supplier, user: user) }
  let(:product) { create(:product, name: 'Farine T55', user: user) }

  describe '.call' do
    context 'sans achats actifs' do
      it 'retourne nil' do
        expect(described_class.call(product)).to be_nil
      end
    end

    context 'avec 1 seul achat actif' do
      it 'retourne nil' do
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 5.0, package_unit: 'kg')
        expect(described_class.call(product)).to be_nil
      end
    end

    context 'avec 2+ achats actifs' do
      it 'calcule le CV correctement (écart type population ÷ N)' do
        # prix/kg = 2.0 et 4.0
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 4.0, package_unit: 'kg')

        # mean = 3.0, stddev_pop = sqrt(((2-3)^2 + (4-3)^2) / 2) = sqrt(1) = 1.0
        # CV = (1.0 / 3.0) * 100 = 33.33
        expect(described_class.call(product)).to eq(33.33)
      end

      it 'arrondit à 2 décimales' do
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 10.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 12.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 14.0, package_unit: 'kg')

        result = described_class.call(product)
        expect(result).to eq(result.round(2))
      end
    end

    context 'avec achats inactifs' do
      it 'ignore les achats inactifs' do
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, :inactive, product: product, supplier: supplier,
               package_quantity: 1, package_price: 100.0, package_unit: 'kg')

        # 1 seul achat actif → nil
        expect(described_class.call(product)).to be_nil
      end
    end

    context 'avec prix identiques' do
      it 'retourne 0.0 quand tous les prix sont identiques' do
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 5.0, package_unit: 'kg')
        create(:product_purchase, product: product, supplier: supplier,
               package_quantity: 1, package_price: 5.0, package_unit: 'kg')

        expect(described_class.call(product)).to eq(0.0)
      end
    end
  end
end

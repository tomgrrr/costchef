# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductPurchases::PricePerKgCalculator do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user) }
  let(:product) { create(:product, user: user) }

  describe '.call' do
    context 'with kg unit' do
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product, supplier: supplier, package_unit: 'kg',
                                                package_quantity: 25, package_price: 15.0)
      end

      it 'calculates package_quantity_kg and price_per_kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(25.0)
        expect(purchase.price_per_kg).to eq(0.6)
      end
    end

    context 'with g unit' do
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product, supplier: supplier, package_unit: 'g',
                                                package_quantity: 500, package_price: 3.0)
      end

      it 'converts grams to kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(0.5)
        expect(purchase.price_per_kg).to eq(6.0)
      end
    end

    context 'with l unit' do
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product, supplier: supplier, package_unit: 'l', package_quantity: 1,
                                                package_price: 1.20)
      end

      it 'treats 1L as 1kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(1.0)
        expect(purchase.price_per_kg).to eq(1.2)
      end
    end

    context 'with cl unit' do
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product, supplier: supplier, package_unit: 'cl',
                                                package_quantity: 75, package_price: 5.0)
      end

      it 'converts centiliters to kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(0.75)
        expect(purchase.price_per_kg).to be_within(0.0001).of(6.6667)
      end
    end

    context 'with ml unit' do
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product, supplier: supplier, package_unit: 'ml',
                                                package_quantity: 500, package_price: 2.0)
      end

      it 'converts milliliters to kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(0.5)
        expect(purchase.price_per_kg).to eq(4.0)
      end
    end

    context 'with piece unit and unit_weight_kg' do
      let(:product_piece) { create(:product, :piece, user: user, unit_weight_kg: 0.06) }
      let(:purchase) do
        build(:product_purchase, :uncalculated, product: product_piece, supplier: supplier, package_unit: 'piece',
                                                package_quantity: 30, package_price: 6.0)
      end

      it 'multiplies quantity by unit_weight_kg' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to be_within(0.001).of(1.8)
        expect(purchase.price_per_kg).to be_within(0.0001).of(3.3333)
      end
    end

    context 'with piece unit without unit_weight_kg' do
      let(:purchase) do
        p = build(:product_purchase, :uncalculated,
                  product: product,
                  supplier: supplier,
                  package_unit: 'piece',
                  package_quantity: 30,
                  package_price: 6.0,
                  package_quantity_kg: nil,
                  price_per_kg: nil)
        allow(p.product).to receive(:unit_weight_kg).and_return(nil)
        p
      end

      it 'falls back to 0.001 kg floor' do
        described_class.call(purchase)
        expect(purchase.package_quantity_kg).to eq(0.001)
        expect(purchase.price_per_kg).to eq(6000.0)
      end
    end

    it 'does not persist the purchase' do
      purchase = build(:product_purchase, :uncalculated, product: product, supplier: supplier)
      described_class.call(purchase)
      expect(purchase).not_to be_persisted
    end
  end
end

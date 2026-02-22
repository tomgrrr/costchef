# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::AvgPriceRecalculator do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user) }
  let(:product) { create(:product, user: user) }

  describe '.call' do
    context 'with 1 active purchase' do
      before do
        create(:product_purchase, product: product, supplier: supplier,
                                  package_quantity: 10, package_price: 20.0)
      end

      it 'sets avg_price_per_kg to that purchase price' do
        described_class.call(product)
        expect(product.reload.avg_price_per_kg.to_f).to eq(2.0)
      end
    end

    context 'with 2 active purchases (weighted average)' do
      before do
        create(:product_purchase, product: product, supplier: supplier,
                                  package_quantity_kg: 10.0, price_per_kg: 2.0,
                                  package_quantity: 10, package_price: 20.0)
        create(:product_purchase, product: product, supplier: supplier,
                                  package_quantity_kg: 5.0, price_per_kg: 4.0,
                                  package_quantity: 5, package_price: 20.0)
      end

      it 'calculates weighted average: (10*2 + 5*4) / (10+5) = 2.6667' do
        described_class.call(product)
        expect(product.reload.avg_price_per_kg.to_f).to be_within(0.0001).of(2.6667)
      end
    end

    context 'with inactive purchases ignored' do
      before do
        create(:product_purchase, product: product, supplier: supplier,
                                  package_quantity: 10, package_price: 20.0)
        create(:product_purchase, :inactive, product: product, supplier: supplier,
                                             package_quantity: 5, package_price: 500.0)
      end

      it 'only uses active purchases' do
        described_class.call(product)
        expect(product.reload.avg_price_per_kg.to_f).to eq(2.0)
      end
    end

    context 'with 0 active purchases' do
      it 'sets avg_price_per_kg to 0' do
        described_class.call(product)
        expect(product.reload.avg_price_per_kg.to_f).to eq(0.0)
      end
    end

    it 'persists via update_columns' do
      create(:product_purchase, product: product, supplier: supplier,
                                package_quantity: 10, package_price: 35.0)
      described_class.call(product)
      expect(product.reload.avg_price_per_kg.to_f).to eq(3.5)
    end
  end
end

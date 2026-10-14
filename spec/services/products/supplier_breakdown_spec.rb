# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::SupplierBreakdown do
  let(:user) { create(:user) }
  let(:product) { create(:product, user: user, name: 'Canard', avg_price_per_kg: 15) }
  let(:allier) { create(:supplier, user: user, name: 'Allier volailles') }
  let(:metro) { create(:supplier, user: user, name: 'Metro') }

  def buy(supplier, quantity, price, active: true)
    create(:product_purchase, product: product, supplier: supplier, package_quantity: quantity,
                              package_quantity_kg: quantity, package_unit: 'kg', package_price: price, active: active)
  end

  it 'raises without a product' do
    expect { described_class.call(nil) }.to raise_error(ArgumentError)
  end

  it 'returns an empty list without active purchases' do
    buy(metro, 1, 12, active: false)
    expect(described_class.call(product)).to eq([])
  end

  it 'averages each supplier weighted by quantity, cheapest first' do
    buy(allier, 2.5, 42)   # 16.80 / kg
    buy(allier, 2.5, 36)   # 14.40 / kg
    buy(metro, 1, 12.3)    # 12.30 / kg

    result = described_class.call(product)

    expect(result.map { |l| l[:supplier] }).to eq([metro, allier])
    expect(result.last[:avg_price_per_kg]).to eq(15.6)
    expect(result.last[:purchases_count]).to eq(2)
  end

  it 'compares each supplier with the overall average' do
    buy(metro, 1, 12)

    expect(described_class.call(product).first[:delta_pct]).to eq(-20.0)
  end

  it 'leaves the comparison empty when the product has no average yet' do
    product.update_column(:avg_price_per_kg, 0)
    buy(metro, 1, 12)

    expect(described_class.call(product).first[:delta_pct]).to be_nil
  end
end

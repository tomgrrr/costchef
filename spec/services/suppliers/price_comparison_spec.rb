# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Suppliers::PriceComparison do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user, name: 'Allier volailles') }
  let(:canard) { create(:product, user: user, name: 'Canard', avg_price_per_kg: 15) }
  let(:poulet) { create(:product, user: user, name: 'Poulet', avg_price_per_kg: 0) }

  def buy(product, quantity, price, active: true)
    create(:product_purchase, product: product, supplier: supplier, package_quantity: quantity,
                              package_quantity_kg: quantity, package_unit: 'kg', package_price: price, active: active)
  end

  it 'raises without a supplier' do
    expect { described_class.call(nil) }.to raise_error(ArgumentError)
  end

  it 'returns one row per product, sorted by product name' do
    buy(poulet, 1, 7)
    buy(canard, 1, 16)

    expect(described_class.call(supplier).map { |r| r[:product] }).to eq([canard, poulet])
  end

  it 'computes weighted and simple averages on active purchases only' do
    buy(canard, 2.5, 42)              # 16.80
    buy(canard, 2.5, 36)              # 14.40
    buy(canard, 1, 10, active: false) # ignored

    row = described_class.call(supplier).first

    expect(row[:weighted_avg]).to eq(15.6)
    expect(row[:simple_avg]).to eq(15.6)
    expect(row[:active_quantity_kg]).to eq(5)
    expect(row[:purchases].last).not_to be_active
  end

  it 'compares with the product overall average' do
    buy(canard, 1, 16.5)

    expect(described_class.call(supplier).first[:delta_pct]).to eq(10.0)
  end

  it 'has no averages when every purchase is inactive or the product has no price' do
    buy(poulet, 1, 7, active: false)

    row = described_class.call(supplier).first

    expect(row[:weighted_avg]).to be_nil
    expect(row[:global_avg]).to be_nil
    expect(row[:delta_pct]).to be_nil
  end
end

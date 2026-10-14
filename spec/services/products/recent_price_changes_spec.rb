# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::RecentPriceChanges do
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier, user: user) }
  let(:canard) { create(:product, user: user, name: 'Canard') }
  let(:beurre) { create(:product, user: user, name: 'Beurre') }

  def buy(product, price, at)
    create(:product_purchase, product: product, supplier: supplier, package_quantity: 1,
                              package_quantity_kg: 1, package_unit: 'kg', package_price: price, created_at: at)
  end

  it 'raises without a user' do
    expect { described_class.call(nil) }.to raise_error(ArgumentError)
  end

  it 'compares the latest purchase with the one before, newest first' do
    buy(canard, 14.40, 3.days.ago)
    buy(canard, 16.80, 1.day.ago)
    buy(beurre, 8.60, 5.days.ago)
    buy(beurre, 8.20, 2.days.ago)

    result = described_class.call(user)

    expect(result.map { |c| c[:product] }).to eq([canard, beurre])
    expect(result.first[:delta_pct]).to eq(16.7)
    expect(result.last[:delta_pct]).to eq(-4.7)
  end

  it 'ignores products with a single purchase or an unchanged price' do
    buy(canard, 10, 2.days.ago)
    buy(beurre, 8, 3.days.ago)
    buy(beurre, 8, 1.day.ago)

    expect(described_class.call(user)).to eq([])
  end

  it 'counts the recipes using each changed product' do
    buy(canard, 10, 2.days.ago)
    buy(canard, 12, 1.day.ago)
    create(:recipe_component, parent_recipe: create(:recipe, user: user), component: canard)

    expect(described_class.call(user).first[:recipes_count]).to eq(1)
  end

  it "never returns another user's purchases" do
    other = create(:user, email: 'other@test.fr')
    other_product = create(:product, user: other, name: 'Secret')
    other_supplier = create(:supplier, user: other)
    create(:product_purchase, product: other_product, supplier: other_supplier, package_price: 1, created_at: 2.days.ago)
    create(:product_purchase, product: other_product, supplier: other_supplier, package_price: 5, created_at: 1.day.ago)

    expect(described_class.call(user)).to eq([])
  end
end

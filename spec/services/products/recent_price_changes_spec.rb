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

  it 'keeps a change even when another product has many newer purchases' do
    buy(beurre, 8, 40.days.ago)
    buy(beurre, 10, 30.days.ago)
    30.times { |i| buy(canard, 12, (29 - i).days.ago) }

    expect(described_class.call(user).map { |c| c[:product] }).to eq([beurre])
  end

  it 'compares with the purchase just before, even an inactive one' do
    buy(canard, 10, 3.days.ago).update!(active: false)
    buy(canard, 12, 1.day.ago)

    expect(described_class.call(user).first[:delta_pct]).to eq(20.0)
  end

  it 'runs the same number of queries whatever the number of products' do
    queries_for = lambda do
      count = 0
      counter = ->(*, payload) { count += 1 unless payload[:name].in?(%w[SCHEMA TRANSACTION]) }
      ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { described_class.call(user) }
      count
    end
    buy(canard, 10, 2.days.ago)
    buy(canard, 12, 1.day.ago)
    few = queries_for.call
    %w[Farine Sel Oeuf Lait].each_with_index do |name, i|
      product = create(:product, user: user, name: name)
      buy(product, 5, (10 + i).days.ago)
      buy(product, 6, (5 + i).days.ago)
    end

    expect(queries_for.call).to eq(few)
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

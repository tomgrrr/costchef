# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::CostBreakdown do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }

  def add(name, price, quantity_kg)
    product = create(:product, name: name, user: user, avg_price_per_kg: price)
    create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: quantity_kg)
  end

  it 'raises without a recipe' do
    expect { described_class.call(nil) }.to raise_error(ArgumentError)
  end

  it 'returns an empty list when nothing has a cost' do
    add('Sel', 0, 1)
    expect(described_class.call(recipe.reload)).to eq([])
  end

  it 'sorts lines by cost and computes each share of the total' do
    add('Canard', 15, 2)  # 30
    add('Beurre', 10, 1)  # 10

    result = described_class.call(recipe.reload)

    expect(result.map { |l| l[:name] }).to eq(%w[Canard Beurre])
    expect(result.map { |l| l[:share] }).to eq([75.0, 25.0])
  end

  it 'groups everything after the top lines as "Autres"' do
    add('A', 10, 4)  # 40
    add('B', 10, 3)  # 30
    add('C', 10, 2)  # 20
    add('D', 10, 1)  # 10

    result = described_class.call(recipe.reload, top: 2)

    expect(result.map { |l| l[:name] }).to eq(%w[A B Autres])
    expect(result.last[:cost]).to eq(30)
    expect(result.sum { |l| l[:share] }).to eq(100.0)
  end

  it 'ignores ingredients without a price' do
    add('Canard', 15, 2)
    add('Sel', 0, 1)

    expect(described_class.call(recipe.reload).map { |l| l[:name] }).to eq(['Canard'])
  end
end

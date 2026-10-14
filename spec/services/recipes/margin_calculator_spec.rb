# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::MarginCalculator do
  let(:user) { create(:user, markup_coefficient: 2.5) }

  it 'raises without a recipe' do
    expect { described_class.call(nil) }.to raise_error(ArgumentError)
  end

  it 'returns the margin per kg and its share of the price' do
    recipe = create(:recipe, user: user, cached_cost_per_kg: 6.92)

    result = described_class.call(recipe)

    expect(result[:per_kg]).to eq(10.38)
    expect(result[:rate]).to eq(60)
  end

  it 'returns nil when the recipe has no cost yet' do
    expect(described_class.call(create(:recipe, user: user, cached_cost_per_kg: 0))).to be_nil
  end

  it 'returns nil when the coefficient does not cover the cost' do
    user.update!(markup_coefficient: 1)
    expect(described_class.call(create(:recipe, user: user, cached_cost_per_kg: 5))).to be_nil
  end
end

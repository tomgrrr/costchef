# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Suppliers::PurchaseStats do
  let(:user) { create(:user) }
  let(:metro) { create(:supplier, user: user, name: 'Metro') }
  let(:colin) { create(:supplier, user: user, name: 'Colin') }

  it 'returns an empty hash without suppliers' do
    expect(described_class.call([])).to eq({})
  end

  it 'counts purchases, active purchases and distinct products per supplier' do
    farine = create(:product, user: user, name: 'Farine')
    beurre = create(:product, user: user, name: 'Beurre')
    create(:product_purchase, product: farine, supplier: metro)
    create(:product_purchase, product: farine, supplier: metro, active: false)
    create(:product_purchase, product: beurre, supplier: metro)

    stats = described_class.call([metro.id, colin.id])

    expect(stats[metro.id]).to include(total: 3, active: 2, products: 2)
    expect(stats[metro.id][:last]).to be_present
    expect(stats).not_to have_key(colin.id)
  end
end

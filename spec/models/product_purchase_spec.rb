# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductPurchase, type: :model do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }
  let(:supplier) { create(:supplier, name: 'Metro', user: user) }
  let(:product) { create(:product, name: 'Farine T55', user: user) }

  describe 'validations' do
    context 'package_quantity' do
      it 'est valide avec package_quantity > 0' do
        purchase = build(:product_purchase, product: product, supplier: supplier)
        expect(purchase).to be_valid
      end

      it 'est invalide avec package_quantity = 0' do
        purchase = build(:product_purchase, product: product, supplier: supplier, package_quantity: 0)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:package_quantity]).to be_present
      end
    end

    context 'package_price' do
      it 'est valide avec package_price >= 0' do
        purchase = build(:product_purchase, product: product, supplier: supplier, package_price: 0)
        expect(purchase).to be_valid
      end

      it 'est invalide avec package_price négatif' do
        purchase = build(:product_purchase, product: product, supplier: supplier, package_price: -1)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:package_price]).to be_present
      end
    end

    context 'package_unit' do
      let(:product_piece) { create(:product, :piece, name: 'Oeuf unit', user: user) }

      Units::VALID_UNITS.each do |unit|
        it "est valide avec package_unit #{unit}" do
          prod = unit == 'piece' ? product_piece : product
          purchase = build(:product_purchase, product: prod, supplier: supplier, package_unit: unit)
          expect(purchase).to be_valid
        end
      end

      it 'est invalide avec package_unit invalide' do
        purchase = build(:product_purchase, product: product, supplier: supplier, package_unit: 'tonne')
        expect(purchase).not_to be_valid
        expect(purchase.errors[:package_unit]).to be_present
      end
    end

    context 'callback before_validation calcule les champs dérivés' do
      it 'calcule automatiquement package_quantity_kg et price_per_kg' do
        purchase = build(:product_purchase, product: product, supplier: supplier,
                         package_quantity: 10, package_unit: 'kg', package_price: 20.0,
                         package_quantity_kg: nil, price_per_kg: nil)
        expect(purchase).to be_valid
        expect(purchase.package_quantity_kg).to eq(10.0)
        expect(purchase.price_per_kg).to eq(2.0)
      end

      it 'ne calcule pas si package_unit est absent' do
        purchase = build(:product_purchase, product: product, supplier: supplier,
                         package_unit: nil, package_quantity_kg: nil, price_per_kg: nil)
        purchase.valid?
        expect(purchase.package_quantity_kg).to be_nil
      end

      it 'ne calcule pas si package_quantity est absent' do
        purchase = build(:product_purchase, product: product, supplier: supplier,
                         package_quantity: nil, package_quantity_kg: nil, price_per_kg: nil)
        purchase.valid?
        expect(purchase.package_quantity_kg).to be_nil
      end
    end
  end

  describe 'validation conversion_kg_must_be_positive' do
    it 'est invalide quand la conversion kg donne 0 (piece sans unit_weight_kg)' do
      purchase = build(:product_purchase,
                       product: product, supplier: supplier,
                       package_unit: 'piece', package_quantity: 10, package_price: 5.0)
      allow(purchase.product).to receive(:unit_weight_kg).and_return(nil)

      expect(purchase).not_to be_valid
      expect(purchase.errors[:package_quantity_kg].join).to include('conversion en kg a échoué')
    end

    it 'est valide quand la conversion kg est positive' do
      purchase = build(:product_purchase,
                       product: product, supplier: supplier,
                       package_unit: 'kg', package_quantity: 5, package_price: 10.0)
      expect(purchase).to be_valid
    end
  end

  describe 'validation supplier_belongs_to_same_user' do
    it 'est valide si fournisseur du même user' do
      purchase = build(:product_purchase, product: product, supplier: supplier)
      expect(purchase).to be_valid
    end

    it "est invalide si fournisseur d'un autre user" do
      other_supplier = create(:supplier, name: 'Pomona', user: other_user)
      purchase = build(:product_purchase, product: product, supplier: other_supplier)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:supplier]).to be_present
    end
  end

  describe 'scopes' do
    let!(:active_purchase) do
      create(:product_purchase, product: product, supplier: supplier, active: true)
    end
    let!(:inactive_purchase) do
      create(:product_purchase, product: product, supplier: supplier, active: false)
    end

    describe '.active' do
      it 'retourne uniquement les achats actifs' do
        expect(ProductPurchase.active).to contain_exactly(active_purchase)
      end
    end

    describe '.inactive' do
      it 'retourne uniquement les achats inactifs' do
        expect(ProductPurchase.inactive).to contain_exactly(inactive_purchase)
      end
    end
  end

  describe '#toggle_active!' do
    it 'purchase actif → passe à false' do
      purchase = create(:product_purchase, product: product, supplier: supplier, active: true)
      purchase.toggle_active!
      expect(purchase.reload.active).to be(false)
    end

    it 'purchase inactif → passe à true' do
      purchase = create(:product_purchase, product: product, supplier: supplier, active: false)
      purchase.toggle_active!
      expect(purchase.reload.active).to be(true)
    end
  end

  describe 'defaults' do
    it 'active par défaut true' do
      purchase = ProductPurchase.new
      expect(purchase.active).to be(true)
    end

    it 'package_unit par défaut kg' do
      purchase = ProductPurchase.new
      expect(purchase.package_unit).to eq('kg')
    end
  end
end

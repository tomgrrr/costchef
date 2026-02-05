# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:products).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).dependent(:destroy) }
    it { is_expected.to have_many(:created_invitations).class_name('Invitation').dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:first_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:company_name).is_at_most(255) }
  end

  describe 'Devise validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe 'default values' do
    it 'has subscription_active set to false by default' do
      user = create(:user)
      expect(user.subscription_active).to be false
    end

    it 'has admin set to false by default' do
      user = create(:user)
      expect(user.admin).to be false
    end
  end

  describe 'traits' do
    it 'creates a subscribed user with :subscribed trait' do
      user = create(:user, :subscribed)
      expect(user.subscription_active).to be true
    end

    it 'creates an admin user with :admin trait' do
      user = create(:user, :admin)
      expect(user.admin).to be true
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:created_by_admin).class_name('User') }
  end

  describe 'validations' do
    subject { build(:invitation) }

    it { is_expected.to validate_presence_of(:email) }

    describe 'email uniqueness' do
      before { create(:invitation) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end

    describe 'token uniqueness' do
      before { create(:invitation) }
      it { is_expected.to validate_uniqueness_of(:token) }
    end
  end

  describe 'email format validation' do
    it 'is invalid with an improperly formatted email' do
      invitation = build(:invitation, email: 'invalid-email')
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to be_present
    end

    it 'is valid with a properly formatted email' do
      invitation = build(:invitation, email: 'valid@example.com')
      expect(invitation).to be_valid
    end
  end

  describe 'email not already registered validation' do
    it 'is invalid if email is already used by an existing user' do
      existing_user = create(:user, email: 'taken@example.com')
      invitation = build(:invitation, email: existing_user.email)
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to include('est déjà utilisé par un compte existant')
    end
  end

  describe 'token generation' do
    it 'generates a token automatically on create' do
      invitation = build(:invitation, token: nil)
      invitation.save!
      expect(invitation.token).to be_present
    end

    it 'generates a secure token with sufficient length' do
      invitation = create(:invitation)
      # urlsafe_base64(32) produces ~43 characters
      expect(invitation.token.length).to be >= 40
    end

    it 'generates unique tokens for each invitation' do
      invitation1 = create(:invitation)
      invitation2 = create(:invitation)
      expect(invitation1.token).not_to eq(invitation2.token)
    end
  end

  describe 'expiration' do
    it 'sets expiration to 7 days from now by default' do
      freeze_time do
        invitation = create(:invitation)
        expect(invitation.expires_at).to be_within(1.second).of(7.days.from_now)
      end
    end

    it 'allows custom expiration date' do
      custom_expiration = 3.days.from_now
      invitation = create(:invitation, expires_at: custom_expiration)
      expect(invitation.expires_at).to be_within(1.second).of(custom_expiration)
    end
  end

  describe '#valid_for_signup?' do
    context 'when invitation is unused and not expired' do
      it 'returns true' do
        invitation = create(:invitation)
        expect(invitation.valid_for_signup?).to be true
      end
    end

    context 'when invitation is expired' do
      it 'returns false' do
        invitation = create(:invitation, :expired)
        expect(invitation.valid_for_signup?).to be false
      end
    end

    context 'when invitation is used' do
      it 'returns false' do
        invitation = create(:invitation, :used)
        expect(invitation.valid_for_signup?).to be false
      end
    end

    context 'when invitation is both used and expired' do
      it 'returns false' do
        invitation = create(:invitation, :used, :expired)
        expect(invitation.valid_for_signup?).to be false
      end
    end
  end

  describe '#mark_as_used!' do
    it 'sets used_at to current time' do
      invitation = create(:invitation)
      freeze_time do
        invitation.mark_as_used!
        expect(invitation.used_at).to eq(Time.current)
      end
    end

    it 'persists the change to the database' do
      invitation = create(:invitation)
      invitation.mark_as_used!
      expect(invitation.reload.used_at).to be_present
    end
  end

  describe '#status' do
    it 'returns :pending for valid invitations' do
      invitation = create(:invitation)
      expect(invitation.status).to eq(:pending)
    end

    it 'returns :expired for expired invitations' do
      invitation = create(:invitation, :expired)
      expect(invitation.status).to eq(:expired)
    end

    it 'returns :used for used invitations' do
      invitation = create(:invitation, :used)
      expect(invitation.status).to eq(:used)
    end

    it 'returns :used for used and expired invitations (used takes precedence)' do
      invitation = create(:invitation, :used, :expired)
      expect(invitation.status).to eq(:used)
    end
  end

  describe 'scopes' do
    let!(:pending_invitation) { create(:invitation) }
    let!(:expired_invitation) { create(:invitation, :expired) }
    let!(:used_invitation) { create(:invitation, :used) }

    describe '.pending' do
      it 'returns only pending invitations' do
        expect(Invitation.pending).to contain_exactly(pending_invitation)
      end
    end

    describe '.expired' do
      it 'returns only expired invitations' do
        expect(Invitation.expired).to contain_exactly(expired_invitation)
      end
    end

    describe '.used' do
      it 'returns only used invitations' do
        expect(Invitation.used).to contain_exactly(used_invitation)
      end
    end
  end
end

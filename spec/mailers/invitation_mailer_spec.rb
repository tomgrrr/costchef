require 'rails_helper'

RSpec.describe InvitationMailer, type: :mailer do
  describe '#invite_user' do
    let(:invitation) { create(:invitation) }
    let(:mail) { described_class.invite_user(invitation) }

    it 'rend le sujet correct' do
      expect(mail.subject).to eq('Invitation à rejoindre CostChef')
    end

    it 'envoie au bon destinataire' do
      expect(mail.to).to eq([invitation.email])
    end

    it 'envoie depuis la bonne adresse' do
      expect(mail.from).to eq(['tom.grenie@gmail.com'])
    end

    it 'contient le lien d inscription avec token' do
      expect(mail.body.encoded).to include('signup?token=')
    end

    it 'mentionne l expiration' do
      expect(mail.body.encoded).to include('7 jours')
    end
  end
end

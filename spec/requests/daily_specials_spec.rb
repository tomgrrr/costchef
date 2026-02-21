# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DailySpecials', type: :request do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'GET /daily_specials' do
    context 'non connecté' do
      it 'redirige vers login' do
        get daily_specials_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté sans abonnement' do
      let(:user) { create(:user, email: 'chef@test.fr', subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get daily_specials_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'connecté avec abonnement' do
      before { sign_in user }

      it 'retourne HTTP 200' do
        get daily_specials_path
        expect(response).to have_http_status(:ok)
      end

      it "n'expose pas les entrées d'un autre user" do
        create(:daily_special, user: user, item_name: 'Entrecôte')
        create(:daily_special, user: other_user, item_name: 'Poulet secret')
        get daily_specials_path
        expect(response.body).to include('Entrecôte')
        expect(response.body).not_to include('Poulet secret')
      end
    end
  end

  describe 'POST /daily_specials' do
    before { sign_in user }

    let(:valid_params) do
      { daily_special: { category: 'meat', entry_date: Date.today, item_name: 'Bœuf', cost_per_kg: 12.50 } }
    end

    context 'params valides' do
      it 'crée une entrée et redirige avec notice' do
        expect { post daily_specials_path, params: valid_params }
          .to change(DailySpecial, :count).by(1)
        expect(response).to redirect_to(daily_specials_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'cost_per_kg absent' do
      it 'ne crée pas et affiche alert' do
        expect { post daily_specials_path, params: { daily_special: valid_params[:daily_special].except(:cost_per_kg) } }
          .not_to change(DailySpecial, :count)
        expect(flash[:alert]).to be_present
      end
    end

    context 'cost_per_kg: 0' do
      it 'ne crée pas et affiche alert' do
        expect { post daily_specials_path, params: { daily_special: valid_params[:daily_special].merge(cost_per_kg: 0) } }
          .not_to change(DailySpecial, :count)
        expect(flash[:alert]).to be_present
      end
    end

    context 'item_name absent' do
      it 'ne crée pas et affiche alert' do
        expect { post daily_specials_path, params: { daily_special: valid_params[:daily_special].merge(item_name: '') } }
          .not_to change(DailySpecial, :count)
        expect(flash[:alert]).to be_present
      end
    end

    context 'category invalide' do
      it 'ne crée pas et affiche alert' do
        expect { post daily_specials_path, params: { daily_special: valid_params[:daily_special].merge(category: 'dessert') } }
          .not_to change(DailySpecial, :count)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH /daily_specials/:id' do
    before { sign_in user }

    let!(:entry) { create(:daily_special, user: user, item_name: 'Bœuf') }

    context 'params valides' do
      it 'met à jour et redirige avec notice' do
        patch daily_special_path(entry), params: { daily_special: { item_name: 'Agneau' } }
        expect(entry.reload.item_name).to eq('Agneau')
        expect(response).to redirect_to(daily_specials_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "entrée d'un autre user" do
      let!(:other_entry) { create(:daily_special, user: other_user, item_name: 'Saumon') }

      it 'redirige vers root_path' do
        patch daily_special_path(other_entry), params: { daily_special: { item_name: 'Hack' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /daily_specials/:id' do
    before { sign_in user }

    context 'entrée du user' do
      let!(:entry) { create(:daily_special, user: user) }

      it 'supprime et redirige avec notice' do
        expect { delete daily_special_path(entry) }
          .to change(DailySpecial, :count).by(-1)
        expect(response).to redirect_to(daily_specials_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "entrée d'un autre user" do
      let!(:other_entry) { create(:daily_special, user: other_user) }

      it 'redirige vers root_path' do
        delete daily_special_path(other_entry)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

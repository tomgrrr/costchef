# frozen_string_literal: true

require 'rails_helper'

# data-turbo-confirm opens the branded dialog (app/javascript/confirm_dialog.js)
# instead of the browser's confirm(): the layout must always render it.
RSpec.describe 'Confirmation dialog', type: :request do
  let(:user) { create(:user) }

  it 'is rendered on app pages, with cancel and accept buttons' do
    sign_in user
    get products_path
    dialog = Nokogiri::HTML(response.body).at_css('dialog#confirm-dialog')
    expect(dialog).to be_present
    expect(dialog.at_css('form[method="dialog"] button[value="cancel"]').text).to eq('Annuler')
    expect(dialog.at_css('button[value="accept"][data-confirm-accept]')).to be_present
  end

  it 'is rendered on signed-out pages too' do
    get new_user_session_path
    expect(response.body).to include('id="confirm-dialog"')
  end

  it 'is wired into Turbo by the application script' do
    expect(Rails.root.join('app/javascript/application.js').read).to include('import "confirm_dialog"')
    expect(Rails.root.join('config/importmap.rb').read).to include('pin "confirm_dialog"')
    expect(Rails.root.join('app/javascript/confirm_dialog.js').read).to include('Turbo.config.forms.confirm')
  end
end

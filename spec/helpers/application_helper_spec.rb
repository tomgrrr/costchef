# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#safe_back_path' do
    let(:default) { '/recipes' }

    it 'retourne le candidat quand le path est relatif' do
      expect(helper.safe_back_path('/recipes?page=2', default)).to eq('/recipes?page=2')
    end

    it 'retourne le candidat avec query params encodés' do
      expect(helper.safe_back_path('/recipes?tab=subrecipes&search=canard', default))
        .to eq('/recipes?tab=subrecipes&search=canard')
    end

    it 'retourne le default quand candidat nil' do
      expect(helper.safe_back_path(nil, default)).to eq(default)
    end

    it 'retourne le default quand candidat vide' do
      expect(helper.safe_back_path('', default)).to eq(default)
    end

    it 'retourne le default pour URL absolue http' do
      expect(helper.safe_back_path('http://evil.com', default)).to eq(default)
    end

    it 'retourne le default pour URL absolue https' do
      expect(helper.safe_back_path('https://evil.com', default)).to eq(default)
    end

    it 'retourne le default pour URL protocol-relative (//evil.com)' do
      expect(helper.safe_back_path('//evil.com', default)).to eq(default)
    end

    it 'retourne le default pour candidat avec backslash' do
      expect(helper.safe_back_path('/recipes\\@evil.com', default)).to eq(default)
    end

    it 'retourne le default pour candidat avec CRLF (header injection)' do
      expect(helper.safe_back_path("/recipes\r\nLocation: x", default)).to eq(default)
    end

    it 'retourne le default pour candidat avec caractère de contrôle (\\0, \\t)' do
      expect(helper.safe_back_path("/recipes\x00", default)).to eq(default)
      expect(helper.safe_back_path("/recipes\t", default)).to eq(default)
    end

    it 'retourne le default pour candidat non-string' do
      expect(helper.safe_back_path(42, default)).to eq(default)
    end
  end
end

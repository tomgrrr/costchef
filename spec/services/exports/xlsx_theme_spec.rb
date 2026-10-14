# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exports::XlsxTheme do
  let(:package) { described_class.new_package }
  let(:theme) { described_class.new(package.workbook) }

  describe 'couleurs' do
    let(:tokens) { Rails.root.join('app/assets/stylesheets/costchef/_tokens.scss').read }

    def token(name)
      tokens[/--#{name}:\s*#(\h{6})/, 1]&.upcase
    end

    it 'reprend les couleurs de l’app (_tokens.scss)' do
      expect(described_class::BRAND).to eq(token('brand'))
      expect(described_class::CARD).to eq(token('card'))
      expect(described_class::FOREGROUND).to eq(token('foreground'))
    end
  end

  describe '.new_package' do
    it 'signe le fichier CostChef' do
      expect(package.core.creator).to eq('CostChef')
    end
  end

  describe 'styles' do
    it 'crée chaque style une seule fois par classeur' do
      expect(theme.header).to eq(theme.header)
      expect(theme.number(2)).to eq(theme.number(2))
      expect(theme.highlight(2, bold: true)).to eq(theme.highlight(2, bold: true))
    end

    it 'distingue les variantes' do
      styles = [theme.header, theme.title, theme.meta, theme.number(2), theme.number(3),
                theme.total, theme.total(3), theme.highlight, theme.highlight(2)]
      expect(styles.uniq.size).to eq(styles.size)
    end

    it 'met l’en-tête en blanc sur la couleur de marque' do
      xf = package.workbook.styles.cellXfs[theme.header]
      fill = package.workbook.styles.fills[xf.fillId]
      font = package.workbook.styles.fonts[xf.fontId]
      expect(fill.fill_type.fgColor.rgb).to end_with(described_class::BRAND)
      expect(font.color.rgb).to end_with(described_class::WHITE)
    end

    it 'refuse un format de nombre inconnu' do
      expect { theme.number(7) }.to raise_error(KeyError)
    end
  end
end

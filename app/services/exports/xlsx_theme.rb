# frozen_string_literal: true

module Exports
  # CostChef look for Excel exports: the app's colour tokens as Excel colours,
  # and the cell styles every sheet uses. Each style is added to the workbook once.
  #
  #   package = Exports::XlsxTheme.new_package
  #   theme = Exports::XlsxTheme.new(package.workbook)
  #   sheet.add_row ['Recette', 'Coût au kg (€)'], style: theme.header
  class XlsxTheme
    # Literal tokens of costchef/_tokens.scss (the theme spec keeps them equal).
    BRAND = '5A2D4F'
    CARD = 'F5F6F7'
    FOREGROUND = '191A1D'
    # Computed like the CSS: --secondary (brand 8 % on white), --border-strong, --muted-foreground.
    BRAND_TINT = 'F2EEF1'
    BORDER = 'D8D8D9'
    MUTED_TEXT = '6C6C6E'
    WHITE = 'FFFFFF'

    NUMBER_FORMATS = { 0 => '0', 1 => '0.0', 2 => '0.00', 3 => '0.000', percent: '0.0"%"' }.freeze

    def self.new_package
      package = ::Axlsx::Package.new
      package.core.creator = 'CostChef'
      package
    end

    def initialize(workbook)
      @styles = workbook.styles
      @cache = {}
    end

    def title
      style(:title, b: true, sz: 16, fg_color: BRAND)
    end

    def meta
      style(:meta, fg_color: MUTED_TEXT)
    end

    def header
      style(:header, b: true, fg_color: WHITE, bg_color: BRAND, border: { style: :thin, color: BRAND })
    end

    # number(2) -> 0.00, number(3) -> 0.000, number(:percent) -> 12.5%
    def number(format)
      style([:number, format], format_code: NUMBER_FORMATS.fetch(format))
    end

    # Total row cell: bold, with a brand rule above.
    def total(format = nil)
      style([:total, format], b: true, border: { style: :thin, color: BRAND, edges: [:top] }, **format_code(format))
    end

    # Row set apart on the brand tint (sub-recipes, recipe rows of the full export).
    def highlight(format = nil, bold: false)
      style([:highlight, format, bold], bg_color: BRAND_TINT, b: bold, **format_code(format))
    end

    private

    def format_code(format)
      format ? { format_code: NUMBER_FORMATS.fetch(format) } : {}
    end

    def style(key, **options)
      @cache[key] ||= @styles.add_style(**options)
    end
  end
end

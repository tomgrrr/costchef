# frozen_string_literal: true

require 'rails_helper'

# Guardrails for the design system (docs/design-system.md). Colours, sizes
# and fonts live in app/assets/stylesheets/costchef/_tokens.scss only; views
# compose the component classes. Emails are exempt: mail clients need inline
# styles and literal colours.
RSpec.describe 'Design system guard' do
  mail_view = ->(path) { path.include?('_mailer/') || path.include?('/mailer.') }
  views = Dir[Rails.root.join('app/views/**/*.erb')].reject(&mail_view)
  stylesheets = Dir[Rails.root.join('app/assets/stylesheets/costchef/*.scss')].reject { |path| path.end_with?('_tokens.scss') }

  bootstrap_classes = %w[d-none d-flex btn-primary btn-secondary form-control form-select form-label
                         form-check alert-danger alert-success modal-dialog dropdown-menu col-md row]

  views.each do |path|
    relative = Pathname(path).relative_path_from(Rails.root)
    source = File.read(path)

    it "#{relative} has no inline style except CSS custom properties" do
      offenders = source.scan(/style="([^"]*)"/).flatten.reject { |style| style.strip.start_with?('--') }
      expect(offenders).to be_empty, "inline styles: #{offenders.inspect}"
    end

    it "#{relative} has no raw colour" do
      expect(source).not_to match(/#\h{6}\b|#\h{3}\b(?![\w-])|rgba?\(/)
    end

    it "#{relative} has no Bootstrap class or data-bs attribute" do
      classes = source.scan(/class="([^"]*)"/).flatten.flat_map(&:split)
      expect(classes & bootstrap_classes).to be_empty
      expect(source).not_to include('data-bs-')
    end
  end

  stylesheets.each do |path|
    it "#{Pathname(path).relative_path_from(Rails.root)} takes every colour from a token" do
      source = File.read(path).gsub(%r{//.*$}, '')
      expect(source).not_to match(/#\h{3,8}\b|rgba?\(|hsla?\(/)
    end
  end

  it 'defines --brand exactly once, in the tokens file' do
    tokens = File.read(Rails.root.join('app/assets/stylesheets/costchef/_tokens.scss'))
    expect(tokens.scan(/^\s*--brand:/).size).to eq(1)
  end
end

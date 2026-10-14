# frozen_string_literal: true

# Small UI primitives shared by every view. Class names and variants are
# documented in docs/design-system.md; values live in costchef/_tokens.scss.
module UiHelper
  # Bootstrap Icons glyph. Decorative unless a label is given.
  def icon(name, label: nil)
    return tag.i(class: "bi bi-#{name}", role: 'img', "aria-label": label) if label

    tag.i(class: "bi bi-#{name}", "aria-hidden": 'true')
  end

  def status_dot(tone = nil)
    tag.span(class: ['dot', ("dot--#{tone}" if tone)], "aria-hidden": 'true')
  end

  # Neutral pill; tone colours the text, dot adds a status dot.
  def chip(text = nil, tone: nil, dot: nil, &block)
    content = block ? capture(&block) : text
    tag.span(class: ['chip', ("chip--#{tone}" if tone)]) do
      safe_join([(status_dot(dot) if dot), content].compact)
    end
  end

  # Page title block. Actions (buttons, links) go in the block.
  def page_header(title, subtitle: nil, &actions)
    text = tag.div(class: 'page-header__text') do
      safe_join([tag.h1(title, class: 'text-display-lg'),
                 (tag.p(subtitle, class: 'page-header__subtitle') if subtitle)].compact)
    end
    tag.header(class: 'page-header') do
      safe_join([text, (tag.div(capture(&actions), class: 'page-header__actions') if actions)].compact)
    end
  end

  # breadcrumb(["Recettes", recipes_path], "Parmentier") — the last item is the current page.
  def breadcrumb(*items)
    parts = items.map do |item|
      item.is_a?(Array) ? link_to(item[0], item[1]) : tag.span(item, "aria-current": 'page')
    end
    tag.nav(safe_join(parts, tag.span('/', "aria-hidden": 'true')), class: 'breadcrumb', "aria-label": 'Fil d’Ariane')
  end

  # Inline alert in a card: a status dot then the block content.
  def notice_box(tone: :warning, css: nil, &block)
    tag.div(class: ['notice', css]) do
      safe_join([status_dot(tone), tag.div(capture(&block), class: 'notice__text')])
    end
  end

  # An invitation, not an apology: title, one line, optional action in the block.
  def empty_state(title, text = nil, &action)
    tag.div(class: 'empty-state') do
      safe_join([tag.p(title, class: 'empty-state__title'),
                 (tag.p(text, class: 'empty-state__text') if text),
                 (tag.div(capture(&action), class: 'empty-state__action') if action)].compact)
    end
  end

  # Sidebar entry; aria-current marks the active section.
  def sidebar_link(label, path, icon_name:, active:, count: nil)
    link_to path, class: 'sidebar__link', "aria-current": (active ? 'page' : nil) do
      safe_join([icon(icon_name), label, (tag.span(count, class: 'sidebar__count') if count)].compact)
    end
  end

  # Initials for avatars: "Lassalas Traiteur" -> "LT".
  def initials_for(text)
    text.to_s.split(/[\s@._-]+/).reject(&:blank?).first(2).map { |w| w[0] }.join.upcase
  end
end

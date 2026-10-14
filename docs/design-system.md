# CostChef — design system

The UI is built from **tokens** (values) and **component classes** (how things look),
composed in ERB views through a few **helpers**. Token *names* follow Bureau Core
(`Pillet-Grenie-Bureau/bureau-design-system`, `core/vocabulary.json`); the *values* are
CostChef's own, in the "app" expression (compact type, small radii, quiet motion).

No Bootstrap. No Tailwind. Plain SCSS compiled by `cssbundling-rails` (`yarn build:css`).

## Files

| What | Where |
|---|---|
| Tokens — the only place values live | `app/assets/stylesheets/costchef/_tokens.scss` |
| Reset, type scale, text colours, utilities | `costchef/_base.scss` |
| App shell, sidebar, page header, layout primitives, auth screens | `costchef/_layout.scss` |
| Buttons, fields, switch, segmented control | `costchef/_controls.scss` |
| Card, KPI, price panel, notice, chip, empty state, key/value | `costchef/_surfaces.scss` |
| Table, pagination, tabs, menu, dialog, pickers, meters, charts | `costchef/_collections.scss` |
| Entry point | `app/assets/stylesheets/application.scss` |
| View helpers | `app/helpers/ui_helper.rb`, `format_helper.rb`, `products_helper.rb` |
| Guard spec | `spec/design/design_system_guard_spec.rb` |

## Rules

- **MUST** take every colour, font, size, radius and shadow from a token (`var(--…)`).
  **NEVER** write a hex, `rgb()` or `hsl()` value outside `_tokens.scss`.
- **NEVER** write an inline `style=""` in a view, except to pass a CSS custom property
  (`style="--value: 60%"`, `style="--input-width: 160px"`). The guard spec enforces it.
- Text stays on the ladder: `--foreground` › `--foreground-secondary` › `--muted-foreground`
  › `--subtle-foreground` (placeholders only).
- `--accent` is the neutral hover background. The highlight colour is `--brand`;
  `--brand-text` when it must be read as text.
- `--decor-1…5` are for illustration only (cost breakdown bar, plate bars, dots): never
  for text, borders or states.
- `--destructive` is for errors and destructive actions only. Warnings (missing price,
  unstable price) use `--warning` / `--warning-text`.
- One primary button (`.btn--primary`) per view; everything else is `.btn--outline`
  or `.btn--ghost`.
- One `.price-panel` (the brand tint, `--secondary`) per screen, for the selling price.
- Numbers that line up use `.num` (tabular figures). Money and weights go through
  `eur`, `weight_label`, `percent`, `fr_number` (French formatting, non-breaking spaces).
- Touch targets are 44 px (`--control-height`): kitchens use tablets.
- Light theme only.

To re-colour the app, change `--brand` in `_tokens.scss`. Every tint derives from it.

## Tokens (names)

| Group | Tokens |
|---|---|
| Surfaces | `--background` (white), `--card` (gris perle, every panel), `--popover`, `--surface-raised`, `--surface-inverse`, `--muted` (chips, tiles), `--accent` (hover) |
| Actions | `--primary` (= brand), `--primary-foreground`, `--secondary` (brand tint, price panel), `--secondary-foreground` |
| Text | `--foreground`, `--foreground-secondary`, `--muted-foreground`, `--subtle-foreground` |
| Lines | `--border`, `--border-strong`, `--input`, `--ring` |
| Brand | `--brand`, `--brand-foreground`, `--brand-text` |
| States | `--success`, `--success-text`, `--warning`, `--warning-text`, `--destructive`, `--destructive-foreground`, `--destructive-text` |
| Decor | `--decor-1` farine · `--decor-2` sauge · `--decor-3` lavande · `--decor-4` tomate · `--decor-5` safran |
| Type | `--font-display` (Bricolage Grotesque), `--font-body` (Hanken Grotesk), `--font-mono` (Geist Mono) |
| Space | `--space-1…16`, `--container-max`, `--gutter-outer` |
| Radius | `--radius-sm` 6 · `--radius-md` 10 · `--radius-lg` 14 · `--radius-xl` 20 · `--radius-full` |
| Materials | `--material-raised-shadow`, `--material-overlay-shadow`, `--material-overlay-backdrop` |
| Motion | `--ease-standard`, `--ease-enter`, `--duration-fast`, `--duration-base` |
| Pending Core names | `--primary-hover`, `--secondary-border`, `--brand-selection` (not yet in the Core vocabulary) |

Type scale classes follow Core's `{role}-{size}`: `.text-display-lg/md/sm`,
`.text-heading-md/sm`, `.text-body-md/sm`, `.text-label-md/sm`, `.text-mono-sm`.

## Components

| Component | Classes | Notes |
|---|---|---|
| App shell | `.app`, `.sidebar`, `.app__main`, `.app__content` (`--narrow` for forms) | `layouts/application.html.erb`, `layouts/_sidebar.html.erb` |
| Page header | `page_header(title, subtitle:) { actions }` | owns the `<h1>` |
| Breadcrumb | `breadcrumb(["Produits", products_path], "Farine")` | last item is the current page |
| Button | `.btn` + `--primary` / `--outline` / `--ghost` / `--danger`, `--sm`, `--block` | `.icon-btn` for icon-only (always `aria-label`) |
| Field | `.field` (label wrapper), `.input`, `.field__hint`, `.field__error`, `.affix` + `.affix__suffix/__prefix` | invalid fields get `aria-invalid` |
| Switch | `<input type="checkbox" class="switch" role="switch">` in a `label.switch-row` | real checkbox |
| Segmented | `.seg` + `.seg__item` (links with `aria-current`, or radios `.seg__radio` + label) | filters, VAT, units |
| Card | `.card`, `.card--pad`, `.card__header/__title/__subtitle/__body/__footer`, `.card--link` | gris perle on white |
| KPI | `.card.kpi` + `.kpi__label/__value/__unit/__hint` | |
| Price panel | `.price-panel` + `__label/__value/__section/__row` | brand tint, once per screen |
| Notice | `notice_box(tone:) { … }`, flash in `layouts/_flash.html.erb` | dot + text |
| Chip / dot | `chip(text, tone:, dot:)`, `status_dot(tone)` | tones: success, warning, danger, brand, off |
| Empty state | `empty_state(title, text) { action }` | an invitation, not an apology |
| Table | `.table-wrap` > `table.table` (`--table-min`), `.num`, `.table__link`, `.table__meta`, `.table__actions`, `tr.is-off`, `tr.table__edit`, `tr.table__divider` | real `<table>` |
| Menu | `<details class="menu" data-controller="menu">` + `.menu__panel` / `.menu__item` | positioned so tables never clip it |
| Dialog | `<dialog class="dialog">` opened by `data-action="dialog#open" data-dialog-id-param` | native dialog |
| Tabs | `.tabs` + `.tabs__item[aria-current]` | page-level sections |
| Meter / share bar | `.meter` (`--value`, `--tick`), `.share-bar__part.decor-N` (`--share`) | |
| Chart | `products/_price_chart.html.erb`, geometry from `ProductsHelper#price_chart` | inline SVG |

## Stimulus controllers

`auto-submit`, `char-counter`, `coefficient`, `dialog`, `dismiss`, `menu`, `sidebar`,
`supplier-search`, `toggle-edit` (accepts `id1,id2`), `tray-toggle`, `unified-search`,
`unit-select`, `unit-toggle`. Show/hide always uses the `hidden` attribute.

## Adding a page

1. Start from an existing page of the same kind (list: `recipes/index`, detail:
   `products/show`, form: `recipes/_form`).
2. Use `page_header`, cards, `.table`, helpers — no new colour, no inline style.
3. Missing a component? Add it to the right `costchef/*.scss` file with tokens, and
   document it here.
4. Run `bundle exec rspec spec/design` and `yarn build:css`.

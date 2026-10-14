module ApplicationHelper
  include Pagy::Frontend

  SIDEBAR_SECTIONS = {
    'recipes' => :recipes, 'recipe_components' => :recipes,
    'products' => :products, 'product_purchases' => :products,
    'suppliers' => :suppliers, 'daily_specials' => :daily_specials,
    'standard_deviations' => :variability,
    'tray_sizes' => :settings, 'settings' => :settings
  }.freeze

  # Returns the candidate path if it's a safe internal URL, else the default.
  # Anti open-redirect: only accepts relative paths starting with a single "/"
  # and rejects protocol-relative URLs and backslash escape tricks.
  def safe_back_path(candidate, default)
    return default unless candidate.is_a?(String) && candidate.present?
    return default unless candidate.start_with?('/')
    return default if candidate.start_with?('//')
    return default if candidate.include?('\\')
    return default if candidate.match?(/[[:cntrl:]]/)

    candidate
  end

  # Signed-in, subscribed users (and admins, who skip the subscription gate)
  # get the app shell with the sidebar; everyone else gets the auth screens.
  def app_shell?
    user_signed_in? && (current_user.subscription_active? || current_user.admin?)
  end

  # Which sidebar entry is current for this request.
  def sidebar_section
    return :admin if controller_path.start_with?('admin/')
    return(action_name == 'referentiel_pieces' ? :pieces : :home) if controller_name == 'pages'

    SIDEBAR_SECTIONS[controller_name]
  end

  def account_label
    current_user.company_name.presence || current_user.email
  end
end

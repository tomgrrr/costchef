# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :ensure_subscription!, only: :subscription_required

  def home
    @products_count   = current_user.products.count
    @recipes_count    = current_user.recipes.count
    @suppliers_count  = current_user.suppliers.count
    @tray_sizes_count = current_user.tray_sizes.count
  end

  def subscription_required; end
end

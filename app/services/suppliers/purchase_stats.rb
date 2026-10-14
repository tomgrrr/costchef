# frozen_string_literal: true

module Suppliers
  # Purchase figures for a list of suppliers, in one query: total purchases,
  # active purchases, distinct products and last purchase time. Read-only.
  #
  #   Suppliers::PurchaseStats.call([1, 2])
  #   # => { 1 => { total: 14, active: 11, products: 6, last: <Time> }, ... }
  class PurchaseStats
    def self.call(supplier_ids)
      new(supplier_ids).call
    end

    def initialize(supplier_ids)
      @supplier_ids = Array(supplier_ids)
    end

    def call
      return {} if @supplier_ids.empty?

      rows.to_h { |id, total, active, products, last| [id, { total:, active:, products:, last: }] }
    end

    private

    def rows
      ProductPurchase.where(supplier_id: @supplier_ids).group(:supplier_id)
                     .pluck(:supplier_id, Arel.sql('COUNT(*)'), Arel.sql('COUNT(*) FILTER (WHERE active)'),
                            Arel.sql('COUNT(DISTINCT product_id)'), Arel.sql('MAX(product_purchases.created_at)'))
    end
  end
end

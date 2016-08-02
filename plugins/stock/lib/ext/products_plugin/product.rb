require_dependency 'products_plugin/product'

module ProductsPlugin
  class Product

    attr_accessible :stored, :use_stock

    has_many :stock_allocations, class_name: 'StockPlugin::Allocation'
    has_many :stock_places, through: :stock_allocations, source: :place

    scope :in_stock, -> {where("use_stock is ? or (stored > 0)", nil)}

    extend CurrencyHelper::ClassMethods
    has_number_with_locale :stored

    def in_stock?
      !use_stock or (stored.present? && stored > 0)
    end

    def update_stored
      self.stored = self.stock_allocations.sum(:quantity)
      save
    end
  end
end

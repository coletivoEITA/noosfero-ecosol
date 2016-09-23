require_dependency 'products_plugin/product'

module ProductsPlugin
  class Product

    attr_accessible :stored, :use_stock, :initial_stock

    has_many :stock_allocations, class_name: 'StockPlugin::Allocation'
    has_many :stock_places, through: :stock_allocations, source: :place

    scope :in_stock, -> {where("products.use_stock is ? or products.use_stock = ? or (products.stored > 0)", nil, false)}

    extend CurrencyHelper::ClassMethods
    has_number_with_locale :stored

    def in_stock?
      !use_stock or (stored.present? && stored > 0)
    end

    def update_stored
      self.stored = self.stock_allocations.sum(:quantity)
      save
    end

    def initial_stock= quantity
      if self.use_stock && self.stock_allocations.count == 0
        allocation = self.stock_allocations.build quantity: quantity
        allocation.save!
      end
    end
  end
end

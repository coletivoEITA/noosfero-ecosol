require_dependency 'orders_plugin/order'

module OrdersPlugin
  class Order

    has_many :allocations_orders, class_name: "StockPlugin::AllocationsOrder"
    has_many :stock_allocations, through: :allocations_orders

    after_save :sync_allocations

    def check_stock
      has_out_of_stock_item = false

      self.items.each do |item|
        if item.product.use_stock
          if item.quantity_consumer_ordered > item.product.stored
            item.quantity_consumer_ordered = item.product.stored
            has_out_of_stock_item = true
            item.save!
          end
        end
      end
      has_out_of_stock_item
    end

    def sync_allocations
      if self.status == 'ordered' && self.status_was == 'draft'
        self.create_allocations
      elsif self.status == 'draft' && self.status_was == 'ordered'
        self.stock_allocations.destroy
      end
    end

    def create_allocations
      allocations = []
      self.items.each do |item|
        product = item.from_product
        # when purchase is directly on supplier, get the product instead
        product = item.product if product.nil?
        if product && product.use_stock
          allocation = StockPlugin::Allocation.create product_id: product.id, quantity: (-1 * item.status_quantity), description: "order #{self.id} product #{product.name}"
          allocations << allocation.id
        end
      end
      self.stock_allocation_ids = allocations
    end
  end
end

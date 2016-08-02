require_dependency 'orders_plugin/order'

module OrdersPlugin
  class Order

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
  end
end

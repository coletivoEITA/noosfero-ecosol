require_dependency "orders_plugin/sale"
module OrdersPlugin
  class Sale

    def suppliers_consumer
      @suppliers_consumer ||= SuppliersPlugin::Consumer.where(consumer_id: self.consumer_id, profile_id: self.profile_id).first
    end
  end
end

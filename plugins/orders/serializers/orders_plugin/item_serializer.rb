module OrdersPlugin
  class ItemSerializer < ApplicationSerializer

    attribute :id
    attribute :name
    attribute :supplier_name
    attribute :price
    attribute :unit_name

    attribute :status
    attribute :flags
    attribute :statuses

    attribute :remove_url
    attribute :update_url

    has_one :product, serializer: ItemProductSerializer

    attribute :quantity_consumer_ordered_more_than_stored
    attribute :quantity_consumer_ordered_less_than_minimum

    def flags
      quantity_price_data[:flags]
    end

    def statuses
      quantity_price_data[:statuses]
    end

    def quantity_consumer_ordered_more_than_stored
      scope.instance_variable_get :@quantity_consumer_ordered_more_than_stored
    end
    def quantity_consumer_ordered_less_than_minimum
      scope.instance_variable_get :@quantity_consumer_ordered_less_than_minimum
    end

    ##
    # For admins, removal is only about setting the status quantity to 0
    #
    def remove_url
      unless admin
        scope.url_for controller: :orders_plugin_item, action: :destroy, id: object.id
      end
    end

    def update_url
      if admin
        scope.url_for controller: :orders_plugin_admin_item, action: :edit, id: object.id, actor_name: actor_name
      else
        scope.url_for controller: :orders_plugin_item, action: :edit, id: object.id
      end
    end

    protected

    def quantity_price_data
      @quantity_price_data ||= object.quantity_price_data actor_name
    end

    def actor_name
      instance_options[:actor_name]
    end

    def admin
      scope.instance_variable_get :@admin
    end

  end
end

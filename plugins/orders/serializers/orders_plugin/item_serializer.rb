module OrdersPlugin
  class ItemSerializer < ApplicationSerializer

    attribute :id
    attribute :name
    attribute :supplier_name
    attribute :unit_name

    attribute :price
    attribute :status_quantity
    attribute :status_quantity_localized

    attribute :status
    attribute :flags
    attribute :statuses

    attribute :remove_url
    attribute :update_url

    attribute :quantity_consumer_ordered_more_than_stored

    def flags
      quantity_price_data[:flags]
    end

    def statuses
      quantity_price_data[:statuses]
    end

    def quantity_consumer_ordered_more_than_stored
      scope.instance_variable_get :@quantity_consumer_ordered_more_than_stored
    end

    ##
    # For admins, removal is only about setting the status quantity to 0
    #
    def remove_url
      return unless scope.respond_to? :url_for
      unless admin
        scope.url_for controller: :orders_plugin_item, action: :destroy, id: object.id
      end
    end

    def update_url
      return unless scope.respond_to? :url_for
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

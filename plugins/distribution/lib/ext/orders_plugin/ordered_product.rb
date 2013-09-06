require_dependency 'orders_plugin/ordered_product'

class OrdersPlugin::OrderedProduct

  has_one :supplier, :through => :product

  has_many :sessions, :through => :order, :class_name => 'DistributionPlugin::Session'
  def session
    self.sessions.first
  end

  belongs_to :offered_product, :foreign_key => :product_id, :class_name => 'DistributionPlugin::OfferedProduct'

  named_scope :for_session, lambda { |session| {
      :conditions => ['distribution_plugin_sessions.id = ?', session.id],
      :joins => 'INNER JOIN distribution_plugin_orders ON distribution_plugin_ordered_products.order_id = distribution_plugin_orders.id
        INNER JOIN distribution_plugin_sessions ON distribution_plugin_orders.session_id = distribution_plugin_sessions.id'
    }
  }

end


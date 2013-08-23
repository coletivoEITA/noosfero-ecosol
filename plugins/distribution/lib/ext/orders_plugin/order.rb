require_dependency 'orders_plugin/order'

class OrdersPlugin::Order

  has_many :session_orders, :class_name => 'DistributionPlugin::SessionOrder'
  has_many :sessions, :through => :session_orders
  def session
    self.sessions.first
  end
  def session= session
    self.sessions = [session]
  end

  has_many :offered_products, :through => :products, :source => :offered_product
  has_many :distributed_products, :through => :offered_products, :source => :from_products
  has_many :supplier_products, :through => :distributed_products, :source => :from_products

  has_many :suppliers, :through => :supplier_products, :uniq => true

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products

  named_scope :for_session, lambda { |session| { :conditions => {:session_id => session.id} } }
  named_scope :for_node, lambda { |node| {
      :conditions => ['distribution_plugin_nodes.id = ?', node.id],
      :joins => 'INNER JOIN distribution_plugin_sessions ON distribution_plugin_orders.session_id = distribution_plugin_sessions.id
        INNER JOIN distribution_plugin_nodes ON distribution_plugin_sessions.node_id = distribution_plugin_nodes.id'
    }
  }

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => Proc.new { self.session.orders }

  validates_presence_of :profile

  def delivery?
    self.session.delivery?
  end
  def forgotten?
    self.draft? && !session.orders?
  end
  def open?
    self.draft? && session.orders?
  end

  def code
    I18n.t('distribution_plugin.lib.ext.orders_plugin.order.sessioncode_ordercode') % {
      :sessioncode => self.session.code, :ordercode => self['code']
    }
  end

  alias_method :supplier_delivery!, :supplier_delivery
  def supplier_delivery
    supplier_delivery! || self.session.delivery_methods.first
  end
  def supplier_delivery_id
    self['supplier_delivery_id'] || self.session.delivery_methods.first.id
  end

  protected

end

require_dependency 'orders_plugin/order'

class OrdersPlugin::Order

  has_many :cycle_orders, :class_name => 'OrdersCyclePlugin::CycleOrder'
  has_many :cycles, :through => :cycle_orders
  def cycle
    self.cycles.first
  end
  def cycle= cycle
    self.cycles = [cycle]
  end

  # overhide with stronger eager load
  has_many :items, :class_name => 'OrdersPlugin::Item', :foreign_key => :order_id, :dependent => :destroy,
    :order => 'products.name ASC',
    :include => {:product => [{:from_products => {:from_products => {:sources_from_products => [{:supplier => [{:profile => [:domains, {:environment => :domains}]}]}]}}},
                              {:profile => [:domains, {:environment => :domains}]}, ]}

  has_many :offered_products, :through => :items, :source => :offered_product
  has_many :distributed_products, :through => :offered_products, :source => :from_products
  has_many :supplier_products, :through => :distributed_products, :source => :from_products

  has_many :suppliers, :through => :supplier_products, :uniq => true

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products

  validates_presence_of :profile

  def delivery?
    self.cycle.delivery?
  end
  def forgotten?
    self.draft? and !cycle.orders?
  end
  def open?
    self.draft? and cycle.orders?
  end

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => proc{ if self.cycle then self.cycle.orders else self.profile.orders end }

  def code
    return super unless self.cycle
    I18n.t('orders_cycle_plugin.lib.ext.orders_plugin.order.cyclecode_ordercode') % {
      :cyclecode => self.cycle.code, :ordercode => self['code']
    }
  end

  alias_method :supplier_delivery!, :supplier_delivery
  def supplier_delivery
    self.supplier_delivery! || self.cycle.delivery_methods.first if self.cycle
  end
  def supplier_delivery_id
    self['supplier_delivery_id'] || self.cycle.delivery_methods.first.id
  end

  protected

end

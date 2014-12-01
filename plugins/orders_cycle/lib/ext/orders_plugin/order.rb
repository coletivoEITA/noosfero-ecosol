require_dependency 'orders_plugin/order'

class OrdersPlugin::Order

  attr_accessible :cycle

  def cycles
    []
  end

  def cycle
    self.cycles.first
  end
  def cycle= cycle
    self.cycles = [cycle]
  end

  has_many :offered_products, :through => :items, :source => :offered_product, :uniq => true
  has_many :distributed_products, :through => :offered_products, :source => :from_products, :uniq => true
  has_many :supplier_products, :through => :distributed_products, :source => :from_products, :uniq => true

  has_many :suppliers, :through => :supplier_products, :uniq => true

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => (proc do
    if self.cycle then self.cycle.send(self.orders_name) else self.profile.orders end
  end)

  def code_with_cycle
    return self.code_without_cycle unless self.cycle
    I18n.t('orders_cycle_plugin.lib.ext.orders_plugin.order.cyclecode_ordercode') % {
      :cyclecode => self.cycle.code, :ordercode => self['code']
    }
  end
  alias_method_chain :code, :cycle

  def delivery_methods_with_cycle
    if self.cycle then self.cycle.delivery_methods else self.delivery_methods_without_cycle end
  end
  alias_method_chain :delivery_methods, :cycle

  protected

end

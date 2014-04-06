require_dependency 'orders_plugin/sale'

class OrdersPlugin::Sale

  has_many :cycle_orders, :class_name => 'OrdersCyclePlugin::CycleOrder', :foreign_key => :sale_id, :dependent => :destroy
  has_many :cycles, :through => :cycle_orders, :source => :cycle

  after_save :cycle_change_purchases, :if => :cycle
  before_destroy :cycle_remove_purchases_items, :if => :cycle

  named_scope :for_cycle, lambda{ |cycle| {:conditions => ['orders_cycle_plugin_cycles.id = ?', cycle.id], :joins => [:cycles]} }

  def current_status_with_cycle
    return 'forgotten' if self.forgotten?
    self.current_status_without_cycle
  end
  alias_method_chain :current_status, :cycle

  def delivery?
    self.cycle.delivery?
  end
  def forgotten?
    self.draft? and !self.cycle.orders?
  end

  def open_with_cycle?
    return self.open_without_cycle? if self.cycle.blank?
    self.open_without_cycle? and self.cycle.orders?
  end
  alias_method_chain :open?, :cycle

  def supplier_delivery_with_cycle
    self.supplier_delivery_without_cycle || (self.cycle.delivery_methods.first rescue nil)
  end
  def supplier_delivery_id_with_cycle
    self['supplier_delivery_id'] || (self.cycle.delivery_methods.first.id rescue nil)
  end
  alias_method_chain :supplier_delivery, :cycle

  protected

  # See also: OrdersCyclePlugin::Cycle#generate_purchases
  def cycle_change_purchases
    return unless self.status_was.present?
    if self.status_was != 'confirmed' and self.status == 'confirmed'
      self.cycle_add_purchases_items
    elsif self.status_was == 'confirmed' and self.status != 'confirmed'
      self.cycle_remove_purchases_items
    end
  end

  def cycle_add_purchases_items
    self.offered_products.unarchived.each do |product|
      supplier_product = product.supplier_product
      purchase = supplier_product.purchases.for_cycle(self.cycle).first
      purchase ||= OrdersPlugin::Purchase.create! :cycle => self.cycle, :consumer => self.profile, :profile => product.supplier.profile
      item = purchase.items.for_product(supplier_product).first
      item ||= purchase.items.build :order => self, :product => supplier_product
      item.quantity_asked = product.total_quantity_asked
      item.price_asked = product.total_price_asked
      item.send :update_without_callbacks # dont touch which cause an infinite loop
    end
  end

  def cycle_remove_purchases_items
    self.items.each do |item|
      next unless supplier_product = item.product.supplier_product
      next unless purchase = supplier_product.purchases.for_cycle(self.cycle).first
      purchased_item = purchase.items.for_product(supplier_product).first
      purchased_item.quantity_asked -= item.quantity_asked
      purchased_item.price_asked -= item.quantity_asked
      purchased_item.save!

      purchased_item.destroy if purchased_item.quantity_asked.zero?
      purchase.destroy if purchase.items(true).blank?
    end
  end

end

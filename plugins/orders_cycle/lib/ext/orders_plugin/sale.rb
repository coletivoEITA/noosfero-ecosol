require_dependency 'orders_plugin/sale'

class OrdersPlugin::Sale

  has_many :cycle_orders, class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :sale_id, dependent: :destroy
  has_many :cycles, through: :cycle_orders, source: :cycle

  after_save :cycle_change_purchases, if: :cycle
  before_destroy :cycle_remove_purchases_items, if: :cycle

  scope :for_cycle, lambda{ |cycle| {conditions: ['orders_cycle_plugin_cycles.id = ?', cycle.id], joins: [:cycles]} }

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
    if self.ordered_at_was.nil? and self.ordered_at.present?
      self.cycle_add_purchases_items
    elsif self.ordered_at_was.present? and self.ordered_at.nil?
      self.cycle_remove_purchases_items
    end
  end

  def cycle_add_purchases_items
    ActiveRecord::Base.transaction do
      self.items.each do |item|
        next unless supplier_product = item.product.supplier_product
        next unless supplier = supplier_product.profile

        purchase = self.cycle.purchases.for_profile(supplier).first
        purchase ||= OrdersPlugin::Purchase.create! cycle: self.cycle, consumer: self.profile, profile: supplier

        purchased_item = purchase.items.for_product(supplier_product).first
        purchased_item ||= purchase.items.build order: purchase, product: supplier_product
        purchased_item.quantity_consumer_ordered ||= 0
        purchased_item.quantity_consumer_ordered += item.quantity_consumer_ordered
        purchased_item.price_consumer_ordered ||= 0
        purchased_item.price_consumer_ordered += item.price_consumer_ordered
        purchased_item.save run_callbacks: false # dont touch which cause an infinite loop
      end
    end
  end

  def cycle_remove_purchases_items
    ActiveRecord::Base.transaction do
      self.items.each do |item|
        next unless supplier_product = item.product.supplier_product
        next unless purchase = supplier_product.purchases.for_cycle(self.cycle).first

        purchased_item = purchase.items.for_product(supplier_product).first
        purchased_item.quantity_consumer_ordered -= item.quantity_consumer_ordered
        purchased_item.price_consumer_ordered -= item.price_consumer_ordered
        purchased_item.save!

        purchased_item.destroy if purchased_item.quantity_consumer_ordered.zero?
        purchase.destroy if purchase.items(true).blank?
      end
    end
  end

  handle_asynchronously :cycle_add_purchases_items
  handle_asynchronously :cycle_remove_purchases_items

end

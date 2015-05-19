class OrdersCyclePlugin::Sale < OrdersPlugin::Sale

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_sales, source: :cycle

  after_save :cycle_change_purchases, if: :cycle
  before_destroy :cycle_remove_purchases_items, if: :cycle
  before_validation :fill_default_supplier_delivery

  scope :for_cycle, lambda{ |cycle| {conditions: ['orders_cycle_plugin_cycles.id = ?', cycle.id], joins: [:cycles]} }

  def current_status
    return 'forgotten' if self.forgotten?
    super
  end

  def delivery?
    self.cycle.delivery?
  end
  def forgotten?
    self.draft? and !self.cycle.orders?
  end

  def open?
    super and self.cycle.orders?
  end

  def supplier_delivery
    super || (self.cycle.delivery_methods.first rescue nil)
  end
  def supplier_delivery_id
    self[:supplier_delivery_id] || (self.supplier_delivery.id rescue nil)
  end

  def fill_default_supplier_delivery
    self[:supplier_delivery_id] ||= self.supplier_delivery.id if self.supplier_delivery
  end

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
        purchase ||= OrdersCyclePlugin::Purchase.create! cycle: self.cycle, consumer: self.profile, profile: supplier

        purchased_item = purchase.items.for_product(supplier_product).first
        purchased_item ||= purchase.items.build order: purchase, product: supplier_product
        purchased_item.quantity_consumer_ordered ||= 0
        purchased_item.quantity_consumer_ordered += item.quantity_consumer_ordered
        purchased_item.price_consumer_ordered ||= 0
        purchased_item.price_consumer_ordered += item.quantity_consumer_ordered * supplier_product.price
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
        purchased_item.price_consumer_ordered -= item.quantity_consumer_ordered * supplier_product.price
        purchased_item.save!

        purchased_item.destroy if purchased_item.quantity_consumer_ordered.zero?
        purchase.destroy if purchase.items(true).blank?
      end
    end
  end

  handle_asynchronously :cycle_add_purchases_items
  handle_asynchronously :cycle_remove_purchases_items

end

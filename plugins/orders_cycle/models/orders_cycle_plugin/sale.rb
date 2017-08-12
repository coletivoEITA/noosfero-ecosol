class OrdersCyclePlugin::Sale < OrdersPlugin::Sale

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_sales, source: :cycle

  after_save :change_purchases, if: :cycle
  before_destroy :remove_purchases_items, if: :cycle

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

  def change_purchases
    return unless self.status_was.present?
    # only on sale confirmation
    if self.ordered_at_was.nil? and self.ordered_at.present?
      self.add_purchases_items
    # only on sale cancellation/unconfirmation
    elsif self.ordered_at_was.present? and self.ordered_at.nil?
      self.remove_purchases_items
    end
  end

  def add_purchases_items
    ApplicationRecord.transaction do
      self.items.each do |item|
        self.add_purchase_item item
      end
    end
  end

  def add_purchase_item item
    return unless supplier_product = item.product.supplier_product
    return unless supplier = supplier_product.profile

    purchase = self.cycle.purchases.for_profile(supplier).first
    purchase ||= OrdersCyclePlugin::Purchase.create! cycle: self.cycle, consumer: self.profile, profile: supplier

    purchased_item = purchase.items.for_product(supplier_product).first
    purchased_item ||= purchase.items.build purchase: purchase, product: supplier_product
    purchased_item.quantity_consumer_ordered ||= 0
    purchased_item.quantity_consumer_ordered += item.status_quantity
    purchased_item.price_consumer_ordered ||= 0
    purchased_item.price_consumer_ordered += item.status_quantity * supplier_product.price
    purchased_item.save!
  end

  def update_purchase_item item
    return unless supplier_product = item.product.supplier_product
    return unless supplier = supplier_product.profile

    previous_value = item.quantity_supplier_accepted_was || item.quantity_consumer_ordered
    if previous_value != item.quantity_supplier_accepted
      qtt_diff = (item.quantity_supplier_accepted || 0) - (item.quantity_supplier_accepted_was || 0)
    elsif item.quantity_consumer_ordered_was != item.quantity_consumer_ordered
      qtt_diff = (item.quantity_consumer_ordered || 0) - (item.quantity_consumer_ordered_was || 0)
    else
      return
    end
    return if qtt_diff.zero?

    purchase = self.cycle.purchases.for_profile(supplier).first
    purchased_item = purchase.items.for_product(supplier_product).first
    purchased_item.quantity_consumer_ordered += qtt_diff
    purchased_item.price_consumer_ordered += qtt_diff * supplier_product.price
    purchased_item.save!
  end

  def remove_purchases_items
    ApplicationRecord.transaction do
      self.items.each do |item|
        self.remove_purchase_item item
      end
    end
  end

  def remove_purchase_item item
    return unless supplier_product = item.product.supplier_product
    return unless purchase = supplier_product.orders_cycles_purchases.for_cycle(self.cycle).first

    purchased_item = purchase.items.for_product(supplier_product).first
    purchased_item.quantity_consumer_ordered -= item.status_quantity
    purchased_item.price_consumer_ordered -= item.status_quantity * supplier_product.price
    purchased_item.save!

    purchased_item.destroy if purchased_item.quantity_consumer_ordered.zero?
    purchase.destroy if purchase.items(true).blank?
  end

  handle_asynchronously :add_purchases_items
  handle_asynchronously :remove_purchases_items

end

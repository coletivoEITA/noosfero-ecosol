class OrdersCyclePlugin::Item < OrdersPlugin::Item

  has_one :supplier, through: :product

  belongs_to :offered_product, foreign_key: :product_id, class_name: 'OrdersCyclePlugin::OfferedProduct'

  def cycle
    self.order.cycle
  end

  # OVERIDE from OrdersPlugin::Item
  belongs_to :order, class_name: 'OrdersCyclePlugin::Order', touch: true
  belongs_to :sale, class_name: 'OrdersCyclePlugin::Sale', foreign_key: :order_id
  belongs_to :purchase, class_name: 'OrdersCyclePlugin::Purchase', foreign_key: :order_id

  # OVERIDE from OrdersPlugin::Item
  # FIXME: don't work because of load order
  #if defined? SuppliersPlugin
    has_many :from_products, through: :offered_product
    has_many :to_products, through: :offered_product
    has_many :sources_supplier_products, through: :offered_product
    has_many :supplier_products, through: :offered_product
    has_many :suppliers, through: :offered_product
  #end

  # what items were selled from this item
  def selled_items
    self.order.cycle.selled_items.where(profile_id: self.consumer.id, orders_plugin_item: {product_id: self.product_id})
  end
  # what items were purchased from this item
  def purchased_items
    self.order.cycle.purchases.where(consumer_id: self.profile.id)
  end

end

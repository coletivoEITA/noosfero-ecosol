class OrdersCyclePlugin::OfferedProduct < SuppliersPlugin::BaseProduct

  has_many :cycle_products, :foreign_key => :product_id, :class_name => 'OrdersCyclePlugin::CycleProduct'
  has_many :cycles, :through => :cycle_products, :order => 'name ASC'
  def cycle
    self.cycles.first
  end

  has_many :items, :class_name => 'OrdersPlugin::Item', :foreign_key => :product_id, :dependent => :destroy
  has_many :orders, :through => :items, :source => :order

  named_scope :sources_from_2x_products_joins, :joins =>
    'INNER JOIN suppliers_plugin_source_products sources_from_products_products ON ( products.id = sources_from_products_products.to_product_id ) ' +
    'INNER JOIN products from_products_products ON ( sources_from_products_products.from_product_id = from_products_products.id ) ' +
    'INNER JOIN suppliers_plugin_source_products source_from_products_from_products_products ON ( from_products_products.id = source_from_products_from_products_products.to_product_id ) ' +
    'INNER JOIN suppliers_plugin_suppliers suppliers ON ( suppliers.id = source_from_products_from_products_products.supplier_id )'
  # overhide original. this scope depends on the above one
  named_scope :from_supplier_id, lambda { |supplier_id| { :conditions => ['suppliers.id = ?', supplier_id] } }

  # for products in cycle, these are the products of the suppliers
  # p in cycle -> p distributed -> p from supplier
  has_many :suppliers, :through => :sources_from_2x_products, :order => 'id ASC'
  def sources_supplier_products
    # FIXME: can't use sources_from_2x_products as we can't preload it due to a rails bug
    #self.sources_from_2x_products
    self.from_products.collect(&:sources_from_products).flatten
  end
  def supplier_products
    # FIXME: can't use from_2x_products as we can't preload it due to a rails bug
    #self.from_2x_products
    self.from_products.collect(&:from_products).flatten
  end

  # FIXME: can't preload from_2x_products directly due to a rails bug
  default_scope :include => [{:from_products => {:from_products => {:sources_from_products => [{:supplier => [{:profile => [:domains, {:environment => :domains}]}]}] }} },
                              {:profile => [:domains, {:environment => :domains}]}, ]

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :total_quantity_asked
  has_number_with_locale :total_parcel_quantity
  has_currency :total_price_asked
  has_currency :total_parcel_price
  has_currency :buy_price

  def self.create_from_distributed cycle, product
    op = self.new :profile => product.profile
    op.attributes = product.attributes
    op.type = self.name
    op.freeze_default_attributes product
    op.from_products << product
    cycle.products << op
    op
  end

  def total_quantity_asked
    @total_quantity_asked ||= self.items.confirmed.sum(:quantity_asked)
  end
  def total_price_asked
    @total_price_asked ||= self.items.confirmed.sum(:price_asked)
  end
  def total_parcel_quantity
    #FIXME: convert units and consider stock and availability
    total_quantity_asked
  end
  def total_parcel_price
    buy_price * total_parcel_quantity if buy_price and total_parcel_quantity
  end

  # always recalculate in case something has changed
  def margin_percentage
    return self['margin_percentage'] if price.nil? or buy_price.nil? or price.zero? or buy_price.zero?
    ((price / buy_price) - 1) * 100
  end
  def margin_percentage= value
    self['margin_percentage'] = value
    self.price = self.price_with_margins buy_price
  end

  def buy_price
    self.supplier_products.inject(0){ |sum, p| sum += p.price || 0 }
  end
  def buy_unit
    #TODO: handle multiple products
    unit = (self.supplier_product.unit rescue nil) || self.class.default_unit
  end
  def sell_unit
    self.unit || self.class.default_unit
  end

  # cycle products freezes properties and don't use the original
  DEFAULT_ATTRIBUTES.each do |a|
    define_method "default_#{a}" do
      nil
    end
  end

  FROOZEN_DEFAULT_ATTRIBUTES = DEFAULT_ATTRIBUTES
  def freeze_default_attributes from_product
    FROOZEN_DEFAULT_ATTRIBUTES.each do |a|
      self[a.to_s] = from_product.send a
    end
  end

  protected

  after_update :sync_ordered
  def sync_ordered
    return unless self.price_changed?
    self.items.each do |item|
      item.send :calculate_prices
      item.save!
    end
  end

end

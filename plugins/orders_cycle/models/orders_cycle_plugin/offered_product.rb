class OrdersCyclePlugin::OfferedProduct < SuppliersPlugin::BaseProduct

  has_many :cycle_products, :foreign_key => :product_id, :class_name => 'OrdersCyclePlugin::CycleProduct'
  has_many :cycles, :through => :cycle_products, :order => 'name ASC'
  def cycle
    self.cycles.first
  end

  has_many :ordered_products, :class_name => 'OrdersPlugin::OrderedProduct', :foreign_key => :product_id, :dependent => :destroy
  has_many :orders, :through => :ordered_products, :source => :order

  has_many :sources_from_2x_products, :through => :sources_from_products, :source => :sources_from_products
  has_many :sources_to_2x_products, :through => :sources_to_product, :source => :sources_to_products
  has_many :from_2x_products, :through => :sources_from_2x_products, :source => :from_product
  has_many :to_2x_products, :through => :sources_to_2x_products, :source => :to_product

  # for products in cycle, these are the products of the suppliers
  # p in cycle -> p distributed -> p from supplier
  def supplier_products
    self.from_2x_products
  end

  default_scope :includes => [:from_2x_products]

  validates_presence_of :cycle

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :total_quantity_asked
  has_number_with_locale :total_parcel_quantity
  has_currency :total_price_asked
  has_currency :total_parcel_price
  has_currency :buy_price

  def self.create_from_distributed cycle, product
    sp = self.new :profile => product.profile
    sp.attributes = product.attributes
    sp.type = self.name
    sp.freeze_default_attributes product
    sp.price = sp.price_with_margins product.price, product
    sp.from_products << product
    cycle.products << sp
    sp
  end

  def total_quantity_asked
    @total_quantity_asked ||= self.ordered_products.confirmed.sum(:quantity_asked)
  end
  def total_price_asked
    @total_price_asked ||= self.ordered_products.confirmed.sum(:price_asked)
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
    self.supplier_product ? self.supplier_product.unit : self.class.default_unit
  end
  def sell_unit
    unit
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
    ordered_products.each do |op|
      op.send :calculate_prices
      op.save!
    end
  end

end

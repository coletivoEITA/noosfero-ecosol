class DistributionPluginSessionProduct < DistributionPluginProduct

  belongs_to :session, :class_name => 'DistributionPluginSession'

  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'session_product_id', :dependent => :destroy
  has_many :in_orders, :through => :ordered_products, :source => :order

  validates_presence_of :session
  validate :session_change

  # for products in session, these are the products of the suppliers
  # p in session -> p distributed -> p from supplier
  has_many :from_2x_products, :through => :from_products, :source => :from_products

  def self.create_from_distributed(session, product)
    sp = self.new :node => product.node
    sp.attributes = product.attributes
    sp.type = self.name
    sp.freeze_default_attributes product
    sp.price = sp.price_with_margins(product.price, product)
    sp.from_products << product
    session.products << sp
    sp
  end

  def supplier_products
    self.supplier.nil? ? self.from_2x_products : self.from_2x_products.from_supplier(self.supplier)
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
    #FIXME this breaks fixed margin calculation
    return self['margin_percentage'] if price.nil? or buy_price.nil? or price.zero? or buy_price.zero?
    ((price / buy_price) - 1) * 100
  end

  def margin_percentage=(value)
    self['margin_percentage'] = value
    self.price = price_with_margins buy_price
  end

  def buy_price
    supplier_products.sum(:price)
  end
  def buy_unit
    #TODO: handle multiple products
    supplier_product ? supplier_product.unit : self.class.default_unit
  end
  def sell_unit
    unit
  end

  extend DistributionPlugin::DistributionCurrencyHelper::ClassMethods
  has_currency :buy_price

  # session products freezes properties and don't use the original
  DEFAULT_ATTRIBUTES.each do |a|
    define_method "default_#{a}" do
      nil
    end
  end

  FROOZEN_DEFAULT_ATTRIBUTES = DEFAULT_ATTRIBUTES
  def freeze_default_attributes(from_product)
    FROOZEN_DEFAULT_ATTRIBUTES.each do |a|
      self[a.to_s] = from_product.send a
    end
  end

  protected

  def session_change
    errors.add :session_id, "session can't change" if session_id_changed? and not new_record?
  end

  after_update :sync_ordered
  def sync_ordered
    return unless self.price_changed?
    ordered_products.each do |op|
      op.send :calculate_prices
      op.save!
    end
  end

end

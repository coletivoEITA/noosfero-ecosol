class OrdersCyclePlugin::OfferedProduct < SuppliersPlugin::BaseProduct

  # FIXME: WORKAROUND for https://github.com/rails/rails/issues/6663
  # OrdersCyclePlugin::Sale.find(3697).cycle.suppliers returns empty without this
  def self.finder_needs_type_condition?
    false
  end

  has_many :cycle_products, foreign_key: :product_id, class_name: 'OrdersCyclePlugin::CycleProduct'
  has_many :cycles, through: :cycle_products, order: 'name ASC'
  def cycle
    self.cycles.first
  end

  # OVERRIDE suppliers/lib/ext/product.rb
  # for products in cycle, these are the products of the suppliers
  # p in cycle -> p distributed -> p from supplier
  has_many :suppliers, through: :sources_from_2x_products, order: 'id ASC', uniq: true
  has_many :sources_supplier_products, through: :sources_from_products, source: :sources_from_products
  has_many :supplier_products, through: :sources_from_2x_products, source: :from_product

  instance_exec &OrdersPlugin::Item::DefineTotals
  extend CurrencyHelper::ClassMethods
  has_currency :buy_price

  def self.create_from_distributed cycle, product
    op = self.new
    product.attributes.except('id').each{ |a,v| op.send "#{a}=", v }
    op.profile = product.profile
    op.type = self.name
    op.freeze_default_attributes product
    op.from_products << product
    cycle.products << op
    op
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

  def sell_unit
    self.unit || self.class.default_unit
  end

  # reimplement to don't destroy this, keeping history in cycles
  # offered products copy attributes
  def dependent?
    false
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

  def solr_index?
    false
  end

  protected

  after_update :sync_ordered
  def sync_ordered
    return unless self.price_changed?
    self.items.each do |item|
      item.calculate_prices self.price
      item.save!
    end
  end

end

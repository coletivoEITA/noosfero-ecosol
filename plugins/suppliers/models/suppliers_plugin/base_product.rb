# FIXME remove Base when plugin became a module
class SuppliersPlugin::BaseProduct < Product

  # join source_products
  # FIXME: can't preload :suppliers due to a rails bug
  default_scope :include => [:from_products, {:sources_from_products => [{:supplier => [{:profile => [:domains, {:environment => :domains}]}]}]},
                             {:profile => [:domains, {:environment => :domains}]}]

  self.abstract_class = true

  settings_items :minimum_selleable, :type => Float, :default => nil
  settings_items :margin_percentage, :type => Float, :default => nil
  settings_items :stored, :type => Float, :default => nil
  settings_items :quantity, :type => Float, :default => nil

  DEFAULT_ATTRIBUTES = [
    :name, :description, :price, :unit_id, :product_category_id, :image_id,
    :margin_percentage, :stored, :minimum_selleable, :unit_detail
  ]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :product_category, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :image, :type => :boolean, :default => true, :delegate_to => :supplier_product, :prefix => '_default'
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :unit, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :available, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :profile

  default_item :price, :if => :default_margin_percentage, :delegate_to => proc{ self.supplier_product.price_with_discount if self.supplier_product }
  default_item :unit_detail, :if => :default_unit, :delegate_to => :supplier_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :minimum_selleable, :type => :boolean, :default => true, :delegate_to => :supplier_product

  default_item :product_category_id, :if => :default_product_category, :delegate_to => :supplier_product
  default_item :image_id, :if => :_default_image, :delegate_to => :supplier_product
  default_item :unit_id, :if => :default_unit, :delegate_to => :supplier_product

  extend CurrencyHelper::ClassMethods
  has_currency :own_price
  has_currency :original_price
  has_number_with_locale :minimum_selleable
  has_number_with_locale :own_minimum_selleable
  has_number_with_locale :original_minimum_selleable
  has_number_with_locale :stored
  has_number_with_locale :own_stored
  has_number_with_locale :original_stored
  has_number_with_locale :quantity
  has_number_with_locale :margin_percentage
  has_number_with_locale :own_margin_percentage
  has_number_with_locale :original_margin_percentage

  def self.default_unit
    Unit.new(:singular => I18n.t('suppliers_plugin.models.product.unit'), :plural => I18n.t('suppliers_plugin.models.product.units'))
  end

  # replace available? to use the replaced default_item method
  def available?
    self.available
  end

  def dependent?
    self.from_products.length == 1
  end

  def minimum_selleable
    self['minimum_selleable'] || 0.1
  end

  def price_with_margins base_price = nil, margin_source = nil
    price = 0 unless price
    base_price ||= price
    margin_source ||= self
    ret = base_price

    if margin_source.margin_percentage
      ret += (margin_source.margin_percentage / 100) * ret
    elsif self.profile.margin_percentage
      ret += (self.profile.margin_percentage / 100) * ret
    end

    ret
  end

  def unit_with_default
    unit_without_default || self.class.default_unit
  end
  alias_method_chain :unit, :default

  def archive
    self.update_attributes! :archived => true
  end
  def unarchive
    self.update_attributes! :archived => false
  end

  protected

  def validate_uniqueness_of_column_name?
    false
  end

  # reimplement after_create callback to avoid infinite loop
  def distribute_to_consumers
  end

end

# FIXME remove Base when plugin became a module
class SuppliersPlugin::BaseProduct < Product

  validates_presence_of :name

  settings_items :minimum_selleable, :type => Float, :default => nil
  settings_items :margin_percentage, :type => Float, :default => nil
  settings_items :margin_fixed, :type => Float, :default => nil
  settings_items :stored, :type => Float, :default => nil
  settings_items :quantity, :type => Float, :default => nil
  settings_items :category_id, :type => Integer, :default => nil
  settings_items :type_category_id, :type => Integer, :default => nil

  belongs_to :category, :class_name => 'ProductCategory'
  belongs_to :type_category, :class_name => 'ProductCategory'

  # disable name validation
  validates_uniqueness_of :name, :scope => :profile_id, :allow_nil => true, :if => proc{ |p| false }

  validates_associated :from_products

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage, :margin_fixed,
    :price, :stored, :unit_id, :minimum_selleable, :unit_detail]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_id, :if => :default_price, :delegate_to => :from_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :from_product
  default_item :unit_detail, :if => :default_price, :delegate_to => :from_product

  extend SuppliersPlugin::CurrencyHelper::ClassMethods
  has_number_with_locale :minimum_selleable
  has_number_with_locale :own_minimum_selleable
  has_number_with_locale :original_minimum_selleable
  has_number_with_locale :stored
  has_number_with_locale :own_stored
  has_number_with_locale :original_stored
  has_number_with_locale :quantity
  has_currency :price
  has_currency :own_price
  has_currency :original_price

  def self.default_unit
    Unit.new(:singular => I18n.t('distribution_plugin.models.product.unit'), :plural => I18n.t('distribution_plugin.models.product.units'))
  end

  def minimum_selleable
    self['minimum_selleable'] || 0.1
  end

  def price_with_margins base_price = nil, margin_source = nil
    price = 0 unless price
    base_price ||= price
    ret = base_price

    if margin_source.margin_percentage
      ret += (margin_source.margin_percentage / 100) * ret
    end
    if margin_source.margin_fixed
      ret += margin_source.margin_fixed
    end

    ret
  end

  def unit
    self['unit'] || self.class.default_unit
  end

  def archive
    self.update_attributes! :archived => true
  end
  def unarchive
    self.update_attributes! :archived => false
  end

  alias_method :destroy!, :destroy
  def destroy
    raise "Products shouldn't be destroyed for the sake of the history!"
  end

  protected

end

# FIXME remove Base when plugin became a module
class SuppliersPlugin::BaseProduct < Product

  self.abstract_class = true

  # join source_products
  default_scope :include => [:from_products]

  validates_presence_of :name

  settings_items :minimum_selleable, :type => Float, :default => nil
  settings_items :margin_percentage, :type => Float, :default => nil
  settings_items :stored, :type => Float, :default => nil
  settings_items :quantity, :type => Float, :default => nil
  settings_items :category_id, :type => Integer, :default => nil
  settings_items :type_category_id, :type => Integer, :default => nil

  belongs_to :category, :class_name => 'ProductCategory'
  belongs_to :type_category, :class_name => 'ProductCategory'

  validates_associated :from_products

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage,
    :price, :stored, :unit_id, :minimum_selleable, :unit_detail]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :profile
  default_item :price, :if => :default_margin_percentage, :delegate_to => :from_product
  settings_default_item :unit_id, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_detail, :if => :default_unit_id, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :minimum_selleable, :type => :boolean, :default => true, :delegate_to => :from_product

  extend CurrencyHelper::ClassMethods
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
  has_currency :price
  has_currency :own_price
  has_currency :original_price

  def self.default_unit
    Unit.new(:singular => I18n.t('suppliers_plugin.models.product.unit'), :plural => I18n.t('suppliers_plugin.models.product.units'))
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

  def validate_uniqueness_of_column_name?
    false
  end

end

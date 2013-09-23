# FIXME remove Base when plugin became a module
class SuppliersPlugin::BaseProduct < Product

  self.abstract_class = true

  belongs_to :category, :class_name => 'ProductCategory'
  belongs_to :type_category, :class_name => 'ProductCategory'

  settings_items :minimum_selleable, :type => Float, :default => nil
  settings_items :margin_percentage, :type => Float, :default => nil
  settings_items :stored, :type => Float, :default => nil
  settings_items :quantity, :type => Float, :default => nil
  settings_items :category_id, :type => Integer, :default => nil
  settings_items :type_category_id, :type => Integer, :default => nil

  DEFAULT_ATTRIBUTES = [
    :name, :description, :price, :unit_id, :product_category_id, :image_id,
    :margin_percentage, :stored, :minimum_selleable, :unit_detail
  ]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :product_category, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :image, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :unit, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :profile

  default_item :price, :if => :default_margin_percentage, :delegate_to => proc{ self.from_product.price_with_discount }
  default_item :unit_detail, :if => :default_unit, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :minimum_selleable, :type => :boolean, :default => true, :delegate_to => :from_product

  default_item :product_category_id, :if => :default_product_category, :delegate_to => :from_product
  default_item :image_id, :if => :default_image, :delegate_to => :from_product
  default_item :unit_id, :if => :default_unit, :delegate_to => :from_product

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

  validate :dont_distribute_own

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

  def dont_distribute_own
    self.errors.add :base, I18n.t('suppliers_plugin.models.base_product.own_distribution_error') if self.own?
  end

  # reimplement after_create callback to avoid infinite loop
  def distribute_to_consumers
  end

end

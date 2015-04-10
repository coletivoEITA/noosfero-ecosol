# for some unknown reason, if this is named SuppliersPlugin::Product then
# cycle.products will go to an infinite loop
class SuppliersPlugin::BaseProduct < Product

  attr_accessible :default_margin_percentage, :margin_percentage, :default_stored, :stored, :default_unit, :unit_detail

  default_scope include: [
    # from_products is required for products.available
    :from_products,
    # FIXME: move use cases to a scope called 'includes_for_links'
    {
      suppliers: [{ profile: [:domains, {environment: :domains}] }]
    },
    {
      profile: [:domains, {environment: :domains}]
    }
  ]

  self.abstract_class = true

  settings_items :minimum_selleable, type: Float, default: nil
  settings_items :margin_percentage, type: Float, default: nil
  settings_items :stored, type: Float, default: nil
  settings_items :quantity, type: Float, default: nil
  settings_items :unit_detail, type: String, default: nil

  DEFAULT_ATTRIBUTES = [
    :name, :description, :price, :unit_id, :product_category_id, :image_id,
    :margin_percentage, :stored, :minimum_selleable, :unit_detail
  ]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, type: :boolean, default: true, delegate_to: :supplier_product
  settings_default_item :product_category, type: :boolean, default: true, delegate_to: :supplier_product
  settings_default_item :image, type: :boolean, default: true, delegate_to: :supplier_product, prefix: '_default'
  settings_default_item :description, type: :boolean, default: true, delegate_to: :supplier_product
  settings_default_item :unit, type: :boolean, default: true, delegate_to: :supplier_product
  settings_default_item :available, type: :boolean, default: false, delegate_to: :supplier_product
  settings_default_item :margin_percentage, type: :boolean, default: true, delegate_to: :profile

  default_item :price, if: :default_margin_percentage, delegate_to: proc{ self.supplier_product.price_with_discount if self.supplier_product }
  default_item :unit_detail, if: :default_unit, delegate_to: :supplier_product
  settings_default_item :stored, type: :boolean, default: true, delegate_to: :supplier_product
  settings_default_item :minimum_selleable, type: :boolean, default: true, delegate_to: :supplier_product

  default_item :product_category_id, if: :default_product_category, delegate_to: :supplier_product
  default_item :image_id, if: :_default_image, delegate_to: :supplier_product
  default_item :unit_id, if: :default_unit, delegate_to: :supplier_product

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

  def self.default_product_category environment
    ProductCategory.top_level_for(environment).order('name ASC').first
  end
  def self.default_unit
    Unit.new(singular: I18n.t('suppliers_plugin.models.product.unit'), plural: I18n.t('suppliers_plugin.models.product.units'))
  end

  def self.search_scope scope, params
    scope = scope.from_supplier_id params[:supplier_id] if params[:supplier_id].present?
    scope = scope.with_available(if params[:available] == 'true' then true else false end) if params[:available].present?
    scope = scope.name_like params[:name] if params[:name].present?
    scope = scope.with_product_category_id params[:category_id] if params[:category_id].present?
    scope
  end

  def self.orphans_ids
    # FIXME: need references from rails4 to do it without raw query
    result = self.connection.execute <<-SQL
SELECT products.id FROM products
LEFT OUTER JOIN suppliers_plugin_source_products ON suppliers_plugin_source_products.to_product_id = products.id
LEFT OUTER JOIN products from_products_products ON from_products_products.id = suppliers_plugin_source_products.from_product_id
WHERE products.type IN (#{(self.descendants << self).map{ |d| "'#{d}'" }.join(',')})
GROUP BY products.id HAVING count(from_products_products.id) = 0;
SQL
    result.values
  end

  def self.archive_orphans
    # need full save to trigger search index
    self.where(id: self.orphans_ids).find_each batch_size: 50 do |product|
      product.update_attribute :archived, true
    end
  end

  # replace available? to use the replaced default_item method
  def available?
    self.available
  end

  def available_with_supplier
    self.available_without_supplier and self.supplier_product and self.supplier_product.available and self.supplier.active rescue false
  end
  alias_method_chain :available, :supplier

  def dependent?
    self.from_products.length >= 1
  end
  def orphan?
    !self.dependent?
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
      ret += (margin_source.margin_percentage.to_f / 100) * ret
    elsif self.profile and self.profile.margin_percentage
      ret += (self.profile.margin_percentage.to_f / 100) * ret
    end

    ret
  end

  # just in case the from_products is nil
  def product_category_with_default
    self.product_category_without_default or self.class.default_product_category(self.environment)
  end
  def product_category_id_with_default
    self.product_category_id_without_default or self.product_category_with_default.id
  end
  alias_method_chain :product_category, :default
  alias_method_chain :product_category_id, :default
  def unit_with_default
    self.unit_without_default or self.class.default_unit
  end
  alias_method_chain :unit, :default

  def archive
    self.update_attributes! archived: true
  end
  def unarchive
    self.update_attributes! archived: false
  end

  protected

  def validate_uniqueness_of_column_name?
    false
  end

  # overhide Product's after_create callback to avoid infinite loop
  def distribute_to_consumers
  end

end

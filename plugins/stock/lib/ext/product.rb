require_dependency 'product'

class Product

  attr_accessible :default_stored, :stored

  has_many :stock_allocations, class_name: 'StockPlugin::Allocation'
  has_many :stock_places, through: :stock_allocations, source: :place

  settings_items :stored, type: Float, default: nil

  extend DefaultDelegate::ClassMethods
  default_delegate_setting :stored, to: :supplier_product,
    default_if: -> { self.own_stored.blank? or self.own_stored.zero? }

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :stored
  has_number_with_locale :own_stored
  has_number_with_locale :original_stored

end

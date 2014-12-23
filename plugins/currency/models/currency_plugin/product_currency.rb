class CurrencyPlugin::ProductCurrency < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :product, :currency

  belongs_to :product
  belongs_to :currency, class_name: 'CurrencyPlugin::Currency'

  validates_presence_of :product
  validates_presence_of :currency
  validates_uniqueness_of :currency_id, scope: :product_id

  scope :with_price, conditions: ['price IS NOT NULL']
  scope :with_discount, conditions: ['discount IS NOT NULL']

  delegate :name_with_symbol, to: :currency

  include FloatHelper

  def price= value
    if value.blank?
      super nil
    elsif value.is_a?(String)
      super decimal_to_float(value)
    else
      super value
    end
  end

  def discount= value
    if value.blank?
      super nil
    elsif value.is_a?(String)
      super decimal_to_float(value)
    else
      super value
    end
  end

  def as_json options
    super options.merge(methods: :name_with_symbol, except: [:created_at, :updated_at])
  end

end

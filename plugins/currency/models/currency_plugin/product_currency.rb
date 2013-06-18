class CurrencyPlugin::ProductCurrency < Noosfero::Plugin::ActiveRecord

  belongs_to :product
  belongs_to :currency, :class_name => 'CurrencyPlugin::Currency'

  validates_uniqueness_of :currency_id, :scope => :product_id

  named_scope :with_price, :conditions => ['price IS NOT NULL']
  named_scope :with_discount, :conditions => ['discount IS NOT NULL']

  delegate :name_with_symbol, :to => :currency

  include FloatHelper

  def price= value
    if value.is_a?(String)
      super decimal_to_float(value)
    else
      super value
    end
  end

  def discount= value
    if value.is_a?(String)
      super decimal_to_float(value)
    else
      super value
    end
  end

  def as_json options
    super options.merge(:methods => :name_with_symbol, :except => [:created_at, :updated_at])
  end

end

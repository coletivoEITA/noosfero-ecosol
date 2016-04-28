require_dependency 'product'

class Product

  has_many :product_currencies, -> {
    includes(:currency).order('price IS NOT NULL, discount IS NOT NULL, id ASC')
  }, class_name: 'CurrencyPlugin::ProductCurrency'

  has_many :currencies, through: :product_currencies

  CurrencyFields = [:price, :discount]

  def available_currencies_for_price
    self.enterprise.currencies - self.currencies.with_price
  end
  def available_currencies_for_discount
    self.enterprise.currencies - self.currencies.with_discount
  end
  def available_currencies
    zip = CurrencyFields.zip CurrencyFields.map{ |field| self.send "available_currencies_for_#{field}" }
    Hash[zip]
  end

  def currencies= currencies
    ActiveRecord::Base.transaction do
      self.product_currencies.destroy_all
      currencies.each do |id, attrs|
        next unless attrs.values.select{ |v| v.empty? }.empty?
        self.product_currencies.create attrs.merge(currency_id: id)
      end
    end
  end

  alias_method :orig_price_with_discount, :price_with_discount
  def price_with_discount currency = nil
    return orig_price_with_discount unless currency
    currency.discount ? (currency.price - currency.discount) : currency.price
  end

end

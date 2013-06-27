require_dependency 'environment'

class Environment

  has_many :currencies, :class_name => 'CurrencyPlugin::Currency'

  def currencies_names
    [self.currency_unit] + currencies.map(&:name_with_symbol)
  end

  alias_method :orig_currencies, :currencies
  def currencies
    self.default_currency # create default currency
    self.orig_currencies
  end

  def default_currency
    currency = self.orig_currencies.find_by_symbol self.currency_unit
    if currency.nil?
      currency = self.orig_currencies.build :symbol => self.currency_unit
      currency.save(false)
    end
    currency
  end

end

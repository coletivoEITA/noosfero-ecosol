require_dependency 'enterprise'

class Enterprise

  has_many :enterprise_currencies, class_name: 'CurrencyPlugin::EnterpriseCurrency',
    include: :currency, order: 'id ASC'
  has_many :accepted_currencies, through: :enterprise_currencies, source: :currency,
    conditions: ['currency_plugin_enterprise_currencies.is_organizer <> ?', true], order: 'id ASC'
  has_many :organized_currencies, through: :enterprise_currencies, source: :currency,
    conditions: ['currency_plugin_enterprise_currencies.is_organizer = ?', true], order: 'id ASC'
  has_many :currencies, through: :enterprise_currencies, source: :currency, order: 'id ASC'

  def currencies_with_environment_default
    self.currencies_without_environment_default + [self.environment.default_currency]
  end
  alias_method_chain :currencies, :environment_default

  def other_currencies
    self.environment.currencies - self.currencies
  end

end

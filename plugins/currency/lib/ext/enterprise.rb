require_dependency 'enterprise'

class Enterprise

  has_many :enterprise_currencies, :class_name => 'CurrencyPlugin::EnterpriseCurrency',
    :include => :currency, :order => 'id ASC'
  has_many :accepted_currencies, :through => :enterprise_currencies, :source => :currency,
    :conditions => ['currency_plugin_enterprise_currencies.is_organizer <> ?', true], :order => 'id ASC'
  has_many :organized_currencies, :through => :enterprise_currencies, :source => :currency,
    :conditions => ['currency_plugin_enterprise_currencies.is_organizer = ?', true], :order => 'id ASC'
  has_many :currencies, :through => :enterprise_currencies, :source => :currency, :order => 'id ASC'

  alias_method :orig_currencies, :currencies
  def currencies
    self.orig_currencies + [self.environment.default_currency]
  end

  def other_currencies
    self.environment.currencies - self.currencies
  end

end

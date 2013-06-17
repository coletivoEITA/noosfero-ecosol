class CurrencyPlugin::Currency < Noosfero::Plugin::ActiveRecord

  belongs_to :environment

  has_many :enterprise_currencies, :class_name => 'CurrencyPlugin::EnterpriseCurrency'
  has_many :acceptors, :through => :enterprise_currencies, :source => :enterprise,
    :conditions => ['currency_plugin_enterprise_currencies.is_organizer <> ?', true], :order => 'id ASC'
  has_many :organizers, :through => :enterprise_currencies, :source => :enterprise,
    :conditions => ['currency_plugin_enterprise_currencies.is_organizer = ?', true], :order => 'id ASC'

  has_many :product_currencies
  has_many :products, :through => :product_currencies

  validates_presence_of :environment
  validates_presence_of :symbol, :name, :description

  validates_uniqueness_of :symbol, :scope => :environment_id
  validates_uniqueness_of :name, :scope => :environment_id

  def name_with_symbol
    _('%{name} (%{symbol})') % {:name => self.name, :symbol => self.symbol}
  end
end

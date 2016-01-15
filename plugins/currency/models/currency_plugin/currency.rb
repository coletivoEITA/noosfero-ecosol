class CurrencyPlugin::Currency < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :environment

  belongs_to :environment

  has_many :enterprise_currencies, class_name: 'CurrencyPlugin::EnterpriseCurrency'
  has_many :acceptors, through: :enterprise_currencies, source: :enterprise,
    conditions: ['currency_plugin_enterprise_currencies.is_organizer <> ?', true], order: 'id ASC'
  has_many :organizers, through: :enterprise_currencies, source: :enterprise,
    conditions: ['currency_plugin_enterprise_currencies.is_organizer = ?', true], order: 'id ASC'
  has_many :enterprises, through: :enterprise_currencies, source: :enterprise

  has_many :product_currencies
  has_many :products, through: :product_currencies

  validates_presence_of :environment
  validates_presence_of :symbol
  validates_presence_of :name, :description, unless: :default?
  validate :dont_use_environment_symbol

  validates_uniqueness_of :symbol, scope: :environment_id
  validates_uniqueness_of :name, scope: :environment_id

  scope :with_price, conditions: ['currency_plugin_product_currencies.price IS NOT NULL']
  scope :with_discount, conditions: ['currency_plugin_product_currencies.discount IS NOT NULL']

  def name_with_symbol
    if self.name.present?
      _('%{name} (%{symbol})') % {name: self.name, symbol: self.symbol}
    else
      self.symbol
    end
  end

  def as_json options
    super options.merge(methods: :name_with_symbol, except: [:created_at, :updated_at])
  end

  def default?
    self == self.environment.default_currency
  end

  protected

  def dont_use_environment_symbol
    self.errors.add :symbol, _("can't be equal to environment currency unit") if (not self.default?) and self.symbol.strip == self.environment.currency_unit.strip
  end

end

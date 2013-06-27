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

  validate :dont_use_environment_symbol

  named_scope :with_price, :conditions => ['currency_plugin_product_currencies.price IS NOT NULL']
  named_scope :with_discount, :conditions => ['currency_plugin_product_currencies.discount IS NOT NULL']

  def name_with_symbol
    _('%{name} (%{symbol})') % {:name => self.name, :symbol => self.symbol}
  end

  def as_json options
    super options.merge(:methods => :name_with_symbol, :except => [:created_at, :updated_at])
  end

  protected

  def dont_use_environment_symbol
    self.errors.add :symbol, _("can't be equal to environment currency unit") if self.symbol == environment.currency_unit
  end

end

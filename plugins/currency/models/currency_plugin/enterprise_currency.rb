class CurrencyPlugin::EnterpriseCurrency < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :enterprise, :currency

  belongs_to :enterprise
  belongs_to :currency, class_name: 'CurrencyPlugin::Currency'

  validates_presence_of :enterprise
  validates_presence_of :currency
  validates_uniqueness_of :currency_id, scope: :enterprise_id

  def organizer?
    self.is_organizer
  end

end

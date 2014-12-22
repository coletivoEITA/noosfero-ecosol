class ExchangePlugin::UnregisteredItem < ActiveRecord::Base

  attr_accessible *self.column_names


end

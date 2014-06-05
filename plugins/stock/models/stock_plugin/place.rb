class StockPlugin::Place < Noosfero::Plugin::ActiveRecord

  validates_presence_of :profile
  validates_presence_of :name

  protected

end

class StockPlugin::Place < Noosfero::Plugin::ActiveRecord

  belongs_to :profile

  validates_presence_of :profile
  validates_presence_of :name

  protected

end

class StockPlugin::Place < ActiveRecord::Base

  belongs_to :profile

  validates_presence_of :profile
  validates_presence_of :name

  protected

end

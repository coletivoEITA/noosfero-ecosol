class StockPlugin::Allocation < ActiveRecord::Base

  belongs_to :place, :class_name => 'StockPlugin::Place'
  belongs_to :product

  validates_presence_of :place
  validates_presence_of :product
  validates_numericality_of :quantity, :allow_nil => true

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :quantity

  protected

end

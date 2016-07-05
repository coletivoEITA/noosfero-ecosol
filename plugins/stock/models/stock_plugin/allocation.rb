class StockPlugin::Allocation < ActiveRecord::Base

  belongs_to :place, :class_name => 'StockPlugin::Place'
  belongs_to :product, :class_name => 'ProductPlugin::Product'

  validates_presence_of :place
  validates_presence_of :product
  validates_numericality_of :quantity, :allow_nil => true

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :quantity

  after_create :update_product_counter
  after_destroy :update_product_counter

  protected

  def update_product_counter
    self.product.update_stored
  end

end

class DistributionPluginSourceProduct < ActiveRecord::Base
  belongs_to :from_product, :class_name => "DistributionPluginProduct"
  belongs_to :to_product, :class_name => "DistributionPluginProduct"

  validates_presence_of :from_product
  validates_presence_of :to_product
  validates_numericality_of :quantity, :allow_nil => true

  alias_method :destroy!, :destroy
  def destroy
    to_product.destroy! if to_product
    destroy!
  end

end

require_dependency 'product'

class Product
  has_many :distribution_products, :class_name => 'DistributionPluginProduct', :foreign_key => 'product_id'

  def destroy
    distribution_products.each do |p|
      p.destroy!
    end

    super
  end
end

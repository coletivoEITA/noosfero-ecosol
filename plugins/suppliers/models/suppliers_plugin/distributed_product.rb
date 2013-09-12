class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  validates_presence_of :supplier

  def supplier_product= value
    if value.is_a?(Hash)
      supplier_product.attributes = value if supplier_product
    else
      self.from_products = [value]
    end
  end

  def price
    return self['price'] if own?
    supplier_price = self.supplier_product ? self.supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  def self.json_for_category c
    {
      :id => c.id.to_s, :name => c.full_name(I18n.t('suppliers_plugin.models.distributed_product.greater')), :own_name => c.name,
      :hierarchy => c.hierarchy.map{ |c| {:id => c.id.to_s, :name => c.name, :own_name => c.name,
        :subcats => c.children.map{ |hc| {:id => hc.id.to_s, :name => hc.name} }} },
      :subcats => c.children.map{ |c| {:id => c.id.to_s, :name => c.name} },
    }
  end
  def json_for_category
    self.class.json_for_category(self.product_category)
  end

  protected

end

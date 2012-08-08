class DistributionPluginDistributedProduct < DistributionPluginProduct

  alias_method :default_name_setting, :default_name
  def default_name
    dummy? ? nil : default_name_setting
  end
  alias_method :default_description_setting, :default_description
  def default_description
    dummy? ? nil : default_description_setting
  end

  def price
    return self['price'] if own?
    supplier_price = supplier_product ? supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    price_with_margins = supplier_price

    if margin_percentage
      price_with_margins += (margin_percentage/100)*price_with_margins
    elsif node.margin_percentage
      price_with_margins += (node.margin_percentage/100)*price_with_margins
    end
    if margin_fixed
      price_with_margins += margin_fixed
    elsif node.margin_fixed
      price_with_margins += node.margin_fixed
    end

    price_with_margins
  end

  def supplier_products
    from_products
  end
  def supplier_product
    return from_product if own?
    # automatically create a product for this dummy supplier
    @supplier_product ||= super || (self.dummy? ? DistributionPluginDistributedProduct.new(:node => supplier.node, :supplier => supplier.node.self_supplier) : nil)
  end
  def supplier_product=(value)
    raise "Cannot set supplier's product for own product" if own?
    raise "Cannot set supplier's product details of a non dummy supplier" unless supplier.dummy?
    supplier_product.update_attributes value
  end
  def supplier_product_id
    return nil if own?
    supplier_product.id if supplier_product
  end
  def supplier_product_id=(id)
    raise "Cannot set supplier product for own product" if own?
    distribute_from DistributionPluginProduct.find(id) unless id.blank?
  end

  def distribute_from(product)
    s = node.suppliers.from_node(product.node).first
    raise "Supplier not found" if s.blank?

    self.attributes = product.attributes.merge(:supplier_id => s.id)
    self.supplier = s
    from_products << product unless from_products.include? product
    @supplier_product = product
  end


  def self.json_for_category(c)
    {
      :id => c.id.to_s, :name => c.full_name(_(' > ')), :own_name => c.name,
      :hierarchy => c.hierarchy.map{ |c| {:id => c.id.to_s, :name => c.name, :own_name => c.name,
        :subcats => c.children.map{ |hc| {:id => hc.id.to_s, :name => hc.name} }} },
      :subcats => c.children.map{ |c| {:id => c.id.to_s, :name => c.name} },
    }
  end

  def json_for_category
    self.class.json_for_category(category) if category
  end

  protected

  after_create :create_dummy_supplier_product
  def create_dummy_supplier_product
    # FIXME: use autosave on rails 2.3.x
    if @supplier_product
      @supplier_product.save!
      self.from_products << @supplier_product
    end
  end

end

class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  validates_presence_of :supplier
  validates_presence_of :name, :if => Proc.new { |p| !p.supplier_dummy? }

  after_save :save_self_source

  def own?
    self.supplier.profile == self.profile
  end

  def supplier_product
    r = self.from_product
    return r if r

    if self.new_record? or (!self.own? and self.supplier_dummy?)
      @supplier_product ||= SuppliersPlugin::DistributedProduct.new :profile => self.supplier.profile, :supplier => self.supplier
    end

    @supplier_product
  end
  def supplier_product= value
    if value.is_a?(Hash)
      supplier_product.attributes = value if supplier_product
    else
      @supplier_product = value
    end
  end

  def supplier_product_id
    self.supplier_product.id if self.supplier_product
  end
  def supplier_product_id= id
    self.distribute_from SuppliersPlugin::BaseProduct.find(id) unless id.blank
  end
  # Set _product_ and its supplier as the origin of this product
  def distribute_from product
    s = profile.suppliers.from_profile(product.profile).first
    raise "Supplier not found" if s.blank?

    @supplier_product = product
    self.name ||= product.name
    self.supplier = s
    self.save!
  end

  def price
    return self['price'] if own?
    supplier_price = self.supplier_product ? self.supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  def self.json_for_category(c)
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

  alias_method :super_default_name, :default_name
  def default_name
    self.supplier_dummy? ? nil : super_default_name
  end
  alias_method :super_default_description, :default_description
  def default_description
    self.supplier_dummy? ? nil : super_default_description
  end

  protected

  def save_self_source
    if self.sources_from_products.empty?
      self.sources_from_products.create! :from_product => self.supplier_product, :supplier => self.supplier
      # force save on update
      self.supplier_product.save if self.supplier_product
    end
  end

end

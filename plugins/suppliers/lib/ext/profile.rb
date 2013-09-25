require_dependency 'profile'

class Profile

  has_many :products
  has_many :distributed_products, :class_name => 'SuppliersPlugin::DistributedProduct'

  has_many :suppliers, :class_name => 'SuppliersPlugin::Supplier', :foreign_key => :consumer_id, :dependent => :destroy,
    :include => [{:profile => [:domains], :consumer => [:domains]}], :order => 'name ASC'
  has_many :consumers, :class_name => 'SuppliersPlugin::Consumer', :foreign_key => :profile_id, :dependent => :destroy,
    :include => [{:profile => [:domains], :consumer => [:domains]}], :order => 'name ASC'

  def supplier_settings
    @supplier_settings ||= Noosfero::Plugin::Settings.new self, SuppliersPlugin
  end

  def dummy?
    !self.visible
  end

  def self_supplier
    @self_supplier ||= if new_record?
      self.suppliers_without_self_supplier.build :profile => self
    else
      suppliers_without_self_supplier.of_profile(self).first || self.suppliers_without_self_supplier.create!(:profile => self)
    end
  end
  def suppliers_with_self_supplier
    self_supplier # guarantee that the self_supplier is created
    suppliers_without_self_supplier
  end
  alias_method_chain :suppliers, :self_supplier

  def has_supplier? supplier
    suppliers.include? supplier
  end
  def has_consumer? consumer
    consumers.include? consumer
  end

  def add_supplier supplier
    supplier.add_consumer self
  end
  def remove_supplier supplier
    supplier.remove_consumer self
  end

  def add_consumer consumer
    return if has_consumer? consumer

    consumer.affiliate self, SuppliersPlugin::Supplier::Roles.consumer(self.environment)
    supplier = SuppliersPlugin::Supplier.create!(:profile => self, :consumer => consumer) || suppliers.of_profile(consumer)

    consumer.distribute_supplier_products supplier
    supplier
  end
  def remove_consumer consumer
    consumer.disaffiliate self, SuppliersPlugin::Supplier::Roles.consumer(self.environment)
    supplier = consumers.find_by_consumer_id(consumer.id)

    supplier.destroy if supplier
    supplier
  end

  # see also #distribute_to_consumers
  def distribute_supplier_products supplier
    raise "'#{supplier.name}' is not a supplier of #{self.name}" unless self.has_supplier? supplier
    return if self.person?

    already_supplied = self.products.unarchived.distributed.of_supplier supplier.all
    supplier.products.unarchived.each do |np|
      next if already_supplied.find{ |f| f.supplier_product == np }

      SuppliersPlugin::DistributedProduct.create! :profile => self, :from_products => [np]
    end
  end

  def not_distributed_products supplier
    raise "'#{supplier.name}' is not a supplier of #{self.name}" unless self.has_supplier? supplier

    # FIXME: only select all products if supplier is dummy
    supplier.profile.products.unarchived.own.distributed - self.from_products.unarchived.distributed.by_profile(supplier.profile)
  end

  delegate :margin_percentage, :margin_percentage=, :to => :supplier_settings
  extend CurrencyHelper::ClassMethods
  has_number_with_locale :margin_percentage

  def supplier_products_default_margins
    self.class.transaction do
      self.products.unarchived.distributed.each do |product|
        product.default_margin_percentage = true
        product.save!
      end
    end
  end

end

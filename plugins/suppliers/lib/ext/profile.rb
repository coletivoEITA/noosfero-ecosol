require_dependency 'profile'

class Profile

  has_many :products

  has_many :suppliers, :class_name => 'SuppliersPlugin::Supplier', :foreign_key => :consumer_id, :order => 'name ASC', :dependent => :destroy
  has_many :consumers, :class_name => 'SuppliersPlugin::Supplier', :foreign_key => :profile_id, :order => 'name ASC', :dependent => :destroy

  def supplier_settings
    @supplier_settings ||= Noosfero::Plugin::Settings.new self, SuppliersPlugin
  end

  def dummy?
    !self.visible
  end

  alias_method :orig_suppliers, :suppliers
  def suppliers
    self_supplier # guarantee that the self_supplier is created
    orig_suppliers
  end
  def self_supplier
    return self.orig_suppliers.build(:profile => self) if new_record?
    orig_suppliers.of_profile(self).first || self.orig_suppliers.create!(:profile => self)
  end

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

    consumer.affiliate self, SuppliersPlugin::Supplier::Roles.consumer(self.profile.environment)
    supplier = SuppliersPlugin::Supplier.create!(:profile => self, :consumer => consumer) || suppliers.of_profile(consumer)

    consumer.add_supplier_products supplier unless consumer.consumer?
    supplier
  end
  def remove_consumer consumer
    consumer.disaffiliate self, SuppliersPlugin::Supplier::Roles.consumer(self.profile.environment)
    supplier = consumers.find_by_consumer_id(consumer.id)

    supplier.destroy if supplier
    supplier
  end

  def add_supplier_products supplier
    raise "'#{supplier.name}' is not a supplier of #{self.profile.name}" unless has_supplier? supplier

    already_supplied = self.products.unarchived.distributed.of_supplier supplier.all
    supplier.products.unarchived.each do |np|
      next if already_supplied.find{ |f| f.supplier_product == np }

      p = SuppliersPlugin::DistributedProduct.new :profile => self
      p.distribute_from np
    end
  end

  def not_distributed_products supplier
    raise "'#{supplier.name}' is not a supplier of #{self.profile.name}" unless has_supplier? supplier

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

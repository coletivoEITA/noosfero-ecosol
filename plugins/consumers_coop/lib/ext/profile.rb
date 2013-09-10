require_dependency 'profile'

class Profile

  has_many :offered_products, :class_name => 'OrdersCyclePlugin::OfferedProduct', :dependent => :destroy, :order => 'products.name ASC'

  def consumers_coop_settings
    @consumers_coop_settings ||= Noosfero::Plugin::Settings.new self, ConsumersCoopPlugin
  end

  # belongs_to only works with real attributes :(
  def consumers_coop_header_image
    @consumers_coop_header_image ||= ConsumersCoopPlugin::HeaderImage.find self.consumers_coop_header_image_id
  end
  delegate :consumers_coop_header_image_id, :consumers_coop_header_image_id=, :to => :consumers_coop_settings
  def consumers_coop_header_image_builder= img
    image = self.consumers_coop_header_image
    if image && image.id == img[:id]
      image.attributes = img
    else
      build_consumers_coop_header_image.attributes = img
    end unless img[:uploaded_data].blank?
  end

  def consumers_coop_enable
    self.consumers_coop_add_own_members
    self.consumers_coop_add_own_products
    self.consumers_coop_enable_view
  end
  def consumers_coop_disable
    self.consumers_coop_disable_view
  end

  def consumers_coop_enable_view
    self.profile.update_attribute :theme, 'distribution'

    login_block = self.profile.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    if not login_block
      box = self.profile.boxes.first :conditions => {:position => 2}
      login_block = LoginBlock.create! :box => box
      login_block.move_to_top
    end

    self.profile.home_page = self.profile.blogs.first
    self.profile.save!
  end
  def consumers_coop_disable_view
    self.profile.update_attribute :theme, nil

    login_block = self.profile.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    login_block.destroy if login_block
  end

  def consumers_coop_add_own_members
    profile.members.each{ |member| add_consumer member }
  end
  def consumers_coop_add_own_products
    return unless profile.respond_to? :products

    already_supplied = self.products.unarchived.distributed.from_supplier_id(self.self_supplier.id).all
    profile.products.map do |p|
      already_supplied.find{ |f| f.product == p } ||
        SuppliersPlugin::DistributedProduct.create!(:profile => self, :supplier => self_supplier, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
    end
  end

  def consumers_coop_header_image_save
    consumers_coop_header_image.save if consumers_coop_header_image
  end

  protected

  def abbreviation_or_name
    self['name_abbreviation'] || name
  end

  def build_consumers_coop_header_image
    ConsumersCoopPlugin::HeaderImage.new
  end

end

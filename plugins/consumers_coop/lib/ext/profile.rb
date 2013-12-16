require_dependency 'profile'

class Profile

  has_many :offered_products, :class_name => 'OrdersCyclePlugin::OfferedProduct', :dependent => :destroy, :order => 'products.name ASC'

  def consumers_coop_settings
    @consumers_coop_settings ||= Noosfero::Plugin::Settings.new self, ConsumersCoopPlugin
  end

  # belongs_to only works with real attributes :(
  def consumers_coop_header_image
    @consumers_coop_header_image ||= ConsumersCoopPlugin::HeaderImage.find_by_id self.consumers_coop_header_image_id
  end
  delegate :consumers_coop_header_image_id, :consumers_coop_header_image_id=, :to => :consumers_coop_settings
  def consumers_coop_header_image_builder= img
    image = self.consumers_coop_header_image
    if image
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
    # FIXME don't hardcode
    consumers_coop_theme = 'distribution'
    if Theme.system_themes.collect(&:id).include? consumers_coop_theme
      self.update_attribute :theme, consumers_coop_theme
    end

    login_block = self.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    if not login_block
      box = self.boxes.first :conditions => {:position => 2}
      login_block = LoginBlock.create! :box => box
      login_block.move_to_top
    end

    self.home_page = self.blogs.first
    self.save!
  end
  def consumers_coop_disable_view
    self.update_attribute :theme, nil

    login_block = self.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    login_block.destroy if login_block
  end

  def consumers_coop_add_own_members
    self.members.each{ |member| add_consumer member }
  end
  def consumers_coop_add_own_products
    return unless self.respond_to? :products

    already_supplied = self.distributed_products.unarchived.from_supplier_id(self.self_supplier.id).all
    self.products.map do |p|
      already_supplied.find{ |f| f.product == p } ||
        SuppliersPlugin::DistributedProduct.create!(:profile => self, :supplier => self_supplier, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
    end
  end

  def consumers_coop_header_image_save
    return unless consumers_coop_header_image
    consumers_coop_header_image.save!
    consumers_coop_header_image_id = consumers_coop_header_image.id
    self.save!
  end

  protected

  def abbreviation_or_name
    self.consumers_coop_settings.name_abbreviation.blank? ? self.name : self.consumers_coop_settings.name_abbreviation
  end

  def build_consumers_coop_header_image
    @consumers_coop_header_image = ConsumersCoopPlugin::HeaderImage.new
  end

end

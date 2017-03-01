require_dependency 'profile'

require_dependency 'community'
# attr_accessible must be defined on subclasses
Profile.descendants.each do |subclass|
  subclass.class_eval do
    attr_accessible :consumers_coop_settings
    attr_accessible :volunteers_settings
  end
end

class Profile

  def consumers_coop_settings attrs = {}
    @consumers_coop_settings ||= Noosfero::Plugin::Settings.new self, ConsumersCoopPlugin, attrs
    attrs.each{ |a, v| @consumers_coop_settings.send "#{a}=", v }
    @consumers_coop_settings
  end
  alias_method :consumers_coop_settings=, :consumers_coop_settings

  def consumers_coop_enable
    self.consumers_coop_add_own_members
    self.consumers_coop_add_own_products
    self.consumers_coop_enable_view
    self.consumers_coop_add_own_blocks
  end
  def consumers_coop_disable
    self.consumers_coop_disable_view
    self.consumers_coop_remove_own_blocks
  end

  def consumers_coop_enable_view
    # FIXME don't hardcode
    consumers_coop_theme = 'distribution'
    if Theme.system_themes.collect(&:id).include? consumers_coop_theme
      self.update_attribute :theme, consumers_coop_theme
    end

    self.home_page = self.blogs.first
    self.save!
  end
  def consumers_coop_disable_view
    self.update_attribute :theme, nil
  end

  def consumers_coop_add_own_members
    self.members.each{ |member| add_consumer member }
  end
  def consumers_coop_add_own_products
    return unless self.respond_to? :products

    self.products.own.map do |p|
      next if p.to_products.from_supplier_id(self.id).present?
      #SuppliersPlugin::DistributedProduct.create! profile: self, from_product: p
    end
  end

  def consumers_coop_add_own_blocks
    happening = OrdersCyclePlugin::OrdersCycleHappeningBlock.new title: "Order Cycles Happening", box: self.boxes.where(position: 1).first
    happening.settings = {display:"home_page_only", display_user:"all", language:"all", edit_modes:"none", move_modes:"none"}
    happening.save
    happening.move_to_top
    menu = ConsumersCoopPlugin::ConsumersCoopMenuBlock.new title: "Consumers Coop Menu", box: self.boxes.where(position: 2).first
    menu.save
    menu.move_to_top
  end
  def consumers_coop_remove_own_blocks
    OrdersCyclePlugin::OrdersCycleHappeningBlock.where(title: "Order Cycles Happening", box: self.boxes).destroy_all
  	ConsumersCoopPlugin::ConsumersCoopMenuBlock.where(title: "Consumers Coop Menu", box: self.boxes).destroy_all
  end

  protected

  def abbreviation_or_name
    self.consumers_coop_settings.name_abbreviation.blank? ? self.name : self.consumers_coop_settings.name_abbreviation
  end

end

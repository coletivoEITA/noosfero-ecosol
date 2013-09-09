require_dependency 'profile'

class Profile

  def consumers_coop_settings
    @consumers_coop_settings ||= Noosfero::Plugin::Settings.new self, ConsumersCoopPlugin
  end

  has_many :offered_products, :class_name => 'OrdersCyclePlugin::OfferedProduct', :dependent => :destroy, :order => 'products.name ASC'

end

require_dependency 'profile'
# WORKAROUND: plugin class don't scope subclasses causing core classes conflict
require_dependency File.expand_path "#{File.dirname __FILE__}/../../models/sniffer_plugin/profile"

class Profile

  has_one :sniffer_profile, :class_name => 'SnifferPlugin::Profile'
  has_many :interests, :source => :product_categories, :through => :sniffer_profile
  has_many :opportunities, :source => :opportunities, :through => :sniffer_profile

  def distance
    @distance
  end
  def distance=(value)
    @distance = value
  end

end

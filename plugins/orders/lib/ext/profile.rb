require_dependency 'profile'

class Profile

  has_many :orders, :class_name => 'OrdersPlugin::Order'
  has_many :parcels, :class_name => 'OrdersPlugin::Order', :foreign_key => :consumer_id
  alias_method :purchases, :parcels

  has_many :ordered_products, :through => :orders, :source => :products, :order => 'name ASC'

  # FIXME move to core
  def has_admin? person
    person.has_permission? 'edit_profile', self
  end

end

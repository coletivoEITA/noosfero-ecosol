require_dependency 'profile'

# FIXME move to core
class Profile

  def has_admin? person
    person.has_permission? 'edit_profile', self
  end

end

class Profile

  has_many :orders, :class_name => 'OrdersPlugin::Order'
  alias_method :sales, :orders

  has_many :parcels, :class_name => 'OrdersPlugin::Order', :foreign_key => :consumer_id
  alias_method :purchases, :parcels

  has_many :ordered_products, :through => :orders, :source => :products, :order => 'name ASC'

end

require_dependency 'profile'

class Profile

  has_many :orders, :class_name => 'OrdersPlugin::Order'
  has_many :order_products, :through => :orders, :source => :products, :order => 'name ASC'

  # FIXME move to core
  def has_admin? person
    person.has_permission? 'edit_profile', self
  end

end

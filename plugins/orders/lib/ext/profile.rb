require_dependency 'profile'

class Profile

  has_many :orders, :class_name => 'OrdersPlugin::Order'

  # FIXME move to core
  def has_admin? person
    person.has_permission? 'edit_profile', self
  end

end

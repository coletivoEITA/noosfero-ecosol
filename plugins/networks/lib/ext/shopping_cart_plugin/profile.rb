require_dependency "#{Rails.root}/config/plugins/shopping_cart/lib/ext/profile"

class Profile

  def cart_order_supplier_notification_recipients
    if self.networks_settings.orders_forward == 'orders_managers' and self.orders_managers.present?
      self.orders_managers.collect(&:contact_email) << self.contact_email
    else
      profile = if self.network_node? then self.network else self end
      profile.admins.collect(&:contact_email) << profile.contact_email
    end.compact
  end

end

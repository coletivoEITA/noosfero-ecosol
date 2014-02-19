require_dependency 'profile'

class Profile

  # may be customized by other plugins
  def cart_order_supplier_notification_recipients
    self.contact_email
  end

end

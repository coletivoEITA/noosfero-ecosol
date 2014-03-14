require_dependency 'profile'

class Profile

  # may be customized by other plugins
  def cart_order_supplier_notification_recipients
    (self.admins.collect(&:contact_email) << self.contact_email).select{ |email| email.present? }
  end

end

require_dependency 'profile'

class Profile

  # may be customized by other profiles
  def cart_order_supplier_notification_recipients
    if self.contact_email.present?
      [self.contact_email]
    else
      self.admins.collect(&:contact_email).select{ |email| email.present? }
    end
  end

end

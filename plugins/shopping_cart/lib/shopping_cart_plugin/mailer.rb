class ShoppingCartPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ShoppingCartPlugin::CartHelper

  def get_contact_email(supplier)
    contact_email = []
    if supplier.enterprise?
      if supplier.contact_email.blank?
        supplier.admins.each do |admin|
          contact_email << admin.email
        end
        contact_email
      else
        contact_email << supplier.contact_email
      end
    else
      contact_email
    end
  end

  def customer_notification(customer, supplier, items, delivery_option)
    domain = supplier.hostname || supplier.environment.default_hostname
    recipients    customer[:email]
    from          'no-reply@' + domain
    reply_to      supplier.contact_email
    subject       _("[%s] Your buy request was performed successfully.") % supplier[:name]
    content_type  'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment,
         :helper => self,
         :delivery_option => delivery_option
  end

  def supplier_notification(customer, supplier, items, delivery_option)
    domain = supplier.environment.default_hostname
    recipients    get_contact_email(supplier)
    from          'no-reply@' + domain
    reply_to      customer[:email]
    subject       _("[%s] You have a new buy request from %s.") % [supplier.environment.name, customer[:name]]
    content_type  'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment,
         :helper => self,
         :delivery_option => delivery_option
  end
end

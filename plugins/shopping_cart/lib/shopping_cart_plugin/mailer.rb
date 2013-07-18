class ShoppingCartPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ShoppingCartPlugin::CartHelper

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
    contact_email = []
    if supplier.contact_email.blank?
      supplier.admins do |admin|
        puts 'admins e-mail: %s' % admin.email
        contact_email << admin.email
      end
    else
      contact_email << supplier.contact_email
    end
    recipients    contact_email
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

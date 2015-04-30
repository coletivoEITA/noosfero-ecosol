class ShoppingCartPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ShoppingCartPlugin::CartHelper

  helper ShoppingCartPlugin::CartHelper

  attr_accessor :environment, :profile

  def customer_notification(customer, supplier, items, supplier_delivery)
    domain = supplier.hostname || supplier.environment.default_hostname
    @customer = customer
    @profile = @supplier = supplier
    @environment = supplier.environment
    @items = items
    @helper = self
    @supplier_delivery = supplier_delivery

    mail(
      to:           customer[:email],
      from:         'no-reply@' + domain,
      reply_to:     supplier.contact_email,
      subject:      _("[%s] Your buy request was performed successfully.") % supplier[:name],
      content_type: 'text/html'
    )
  end

  def supplier_notification(customer, supplier, items, supplier_delivery)
    domain = supplier.environment.default_hostname
    @customer = customer
    @profile = @supplier = supplier
    @environment = supplier.environment
    @items = items
    @helper = self
    @supplier_delivery = supplier_delivery

    mail(
      to:    supplier.cart_order_supplier_notification_recipients,
      from:          'no-reply@' + domain,
      reply_to:      customer[:email],
      subject:       _("[%s] You have a new buy request from %s.") % [supplier.environment.name, customer[:name]],
      content_type:  'text/html'
    )
  end
end

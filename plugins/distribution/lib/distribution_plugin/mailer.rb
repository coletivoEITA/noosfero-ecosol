class DistributionPlugin::Mailer < Noosfero::Plugin::MailerBase

  prepend_view_path DistributionPlugin.view_path

  extend DistributionPlugin::DistributionDisplayHelper

  def order_change_notification(node, order, changed, removed, message = nil)
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(order.consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       _("[%{node}] Your order was changed") % {:node => node.name}
    content_type  'text/html'
    body :node => node,
         :order => order,
         :changed => changed,
         :removed => removed,
         :message => message,
         :environment => node.profile.environment
  end

  def order_confirmation(order)
    node = order.session.node
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(order.consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       _("[%{node}] Your order was confirmed") % {:node => node.name}
    content_type  'text/html'
    body :node => node,
         :order => order,
         :consumer => order.consumer,
         :environment => node.profile.environment
  end

  def message_to_consumer_for_order(node, order, subject, message = nil)
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(order.consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       _("[%{node}] %{subject}") % {:node => node.name, :subject => subject}
    content_type  'text/html'
    body :node => node,
         :order => order,
         :consumer => order.consumer,
         :message => message,
         :environment => node.profile.environment
  end

  def message_to_consumer(node, consumer, subject, message)
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       _("[%{node}] %{subject}") % {:node => node.name, :subject => subject}
    content_type  'text/html'
    body :node => node,
         :consumer => consumer,
         :message => message,
         :environment => node.profile.environment
  end

  def message_to_supplier(node, supplier, subject, message)
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(supplier.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       _("[%{node}] %{subject}") % {:node => node.name, :subject => subject}
    content_type  'text/html'
    body :node => node,
         :supplier => supplier,
         :message => message,
         :environment => node.profile.environment
  end

  def message_to_admins(node, member, subject, message)
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(node.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(member.profile)
    subject       _("[%{node}] %{subject}") % {:node => node.name, :subject => subject}
    content_type  'text/html'
    body :node => node,
         :member => member,
         :message => message,
         :environment => node.profile.environment
  end

  private

  def profile_recipients(profile)
    if profile.person?
      profile.contact_email
    else
      profile.admins.map{ |p| p.contact_email }
    end
  end

end

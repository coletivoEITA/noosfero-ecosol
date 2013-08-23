class OrdersPlugin::Mailer < Noosfero::Plugin::MailerBase

  def order_confirmation order, host_with_port
    node = order.session.node
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(order.consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       I18n.t('distribution_plugin.lib.mailer.order_was_confirmed') % {:node => node.name}
    content_type  'text/html'
    body :node => node,
         :order => order,
         :consumer => order.consumer,
         :environment => node.profile.environment,
         :host_with_port => host_with_port
  end

  def order_cancellation order
    node = order.session.node
    domain = node.profile.hostname || node.profile.environment.default_hostname
    recipients    profile_recipients(order.consumer.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(node.profile)
    subject       I18n.t('distribution_plugin.lib.mailer.order_was_cancelled') % {:node => node.name}
    content_type  'text/html'
    body :node => node,
         :order => order,
         :consumer => order.consumer,
         :environment => node.profile.environment
  end

end

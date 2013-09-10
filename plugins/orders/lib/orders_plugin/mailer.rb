# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'

class OrdersPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ActionMailer::Helpers
  helper OrdersPlugin::DisplayHelper
  helper OrdersPlugin::DateHelper

  def order_confirmation order, host_with_port
    profile = order.profile
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(order.consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('orders_plugin.lib.mailer.order_was_confirmed') % {:name => profile.name}
    content_type  'text/html'
    body :profile => profile,
         :order => order,
         :consumer => order.consumer,
         :environment => profile.environment,
         :host_with_port => host_with_port
  end

  def order_cancellation order
    profile = order.profile
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(order.consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('orders_plugin.lib.mailer.order_was_cancelled') % {:name => profile.name}
    content_type  'text/html'
    body :profile => profile,
         :order => order,
         :consumer => order.consumer,
         :environment => profile.environment
  end

  protected

  def profile_recipients profile
    if profile.person?
      profile.contact_email
    else
      profile.admins.map{ |p| p.contact_email }
    end
  end

end

# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ActionMailer::Helpers
  helper ApplicationHelper
  helper OrdersPlugin::OrdersDisplayHelper
  helper OrdersPlugin::DateHelper
  helper SuppliersPlugin::TranslationHelper

  attr_accessor :environment

  def message_to_consumer_for_order profile, order, subject, message = nil
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(order.consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('orders_cycle_plugin.lib.mailer.profile_subject') % {:profile => profile.name, :subject => subject}
    content_type  'text/html'
    body :profile => profile,
         :order => order,
         :consumer => order.consumer,
         :message => message,
         :environment => profile.environment
  end

  def message_to_consumer profile, consumer, subject, message
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('orders_cycle_plugin.lib.mailer.profile_subject') % {:profile => name, :subject => subject}
    content_type  'text/html'
    body :profile => profile,
         :consumer => consumer,
         :message => message,
         :environment => profile.environment
  end

  def order_confirmation order, host_with_port
    profile = order.profile
    domain = profile.hostname || profile.environment.default_hostname
    environment = profile.environment

    recipients    profile_recipients(order.consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('orders_plugin.lib.mailer.order_was_confirmed') % {:name => profile.name}
    content_type  'text/html'
    assigns = {:profile => profile, :order => order, :consumer => order.consumer, :environment => profile.environment, :host_with_port => host_with_port}
    body assigns
    render :file => 'orders_plugin/mailer/order_confirmation', :body => assigns
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

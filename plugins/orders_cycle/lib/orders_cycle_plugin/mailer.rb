class OrdersCyclePlugin::Mailer < Noosfero::Plugin::MailerBase

  include ActionMailer::Helpers
  include OrdersCyclePlugin::TranslationHelper

  helper ApplicationHelper
  helper OrdersCyclePlugin::TranslationHelper

  def order_change_notification profile, order, changed, removed, message = nil
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(order.consumer)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('lib.mailer.order_was_changed') % {:profile => profile}
    content_type  'text/html'
    body :profile => profile,
         :order => order,
         :changed => changed,
         :removed => removed,
         :message => message,
         :environment => profile.environment
  end

  def message_to_supplier profile, supplier, subject, message
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(supplier.profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('lib.mailer.profile_subject') % {:profile => profile.name, :subject => subject}
    content_type  'text/html'
    body :profile => profile,
         :supplier => supplier,
         :message => message,
         :environment => profile.environment
  end

  def message_to_admins profile, member, subject, message
    domain = profile.hostname || profile.environment.default_hostname

    recipients    profile_recipients(profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(member)
    subject       I18n.t('lib.mailer.profile_subject') % {:profile => profile.name, :subject => subject}
    content_type  'text/html'
    body :profile => profile,
         :member => member,
         :message => message,
         :environment => profile.environment
  end

  def open_cycle profile, cycle, subject, message
    domain = profile.hostname || profile.environment.default_hostname

    recipients    organization_members(profile)
    from          'no-reply@' + domain
    reply_to      profile_recipients(profile)
    subject       I18n.t('lib.mailer.profile_subject') % {:profile => profile.name, :subject => subject}
    content_type  'text/html'
    body :profile => profile,
         :cycle => cycle,
         :message => message,
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

  def organization_members profile
    if profile.organization?
      profile.members.map{ |p| p.contact_email }
    end
  end

end

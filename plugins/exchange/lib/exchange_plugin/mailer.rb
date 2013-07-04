class ExchangePlugin::Mailer < Noosfero::Plugin::MailerBase

  def start_exchange_notification(target, origin, exchange_id, message = nil)
    domain = origin.hostname || origin.environment.default_hostname
    recipients    profile_recipients(target)
    from          'no-reply@' + domain
    reply_to      profile_recipients(origin)
    subject       I18n.t('exchange_plugin.lib.mailer.node_start_exchange')
    content_type  'text/html'
    body :target => target,
         :origin => origin,
         :exchange_id => exchange_id
  end

  private

  def profile_recipients(profile)
    if profile.person?
      profile.contact_email
    else
      profile.admins.map{ |p| p.contact_email }
    end
  end

  def community_members(profile)
    if profile.community?
      profile.members.map{ |p| p.contact_email }
    end
  end
end
class ExchangePlugin::Mailer < Noosfero::Plugin::MailerBase

  def start_exchange_notification(target, origin, exchange_id, message = nil)
    domain = origin.hostname || origin.environment.default_hostname
    recipients    profile_recipients(target)
    from          'no-reply@' + domain
    reply_to      profile_recipients(origin)
    subject       _('[ESCAMBO] Vocẽ tem uma nova troca!')
    content_type  'text/html'
    body :target => target,
         :origin => origin,
         :exchange_id => exchange_id
  end
  
  def new_proposal_notification(target, origin, exchange_id, proposal_id, message = nil)
    domain = origin.hostname || origin.environment.default_hostname
    recipients    profile_recipients(target)
    from          'no-reply@' + domain
    reply_to      profile_recipients(origin)
    subject       _('[ESCAMBO] Vocẽ tem uma nova proposta!')
    content_type  'text/html'
    body :target => target,
         :origin => origin,
         :exchange_id => exchange_id,
         :proposal_id => proposal_id
  end
  
  def new_message_notification(sender, recipient, exchange_id, message = nil)
    domain = sender.hostname || sender.environment.default_hostname
    recipients    profile_recipients(recipient)
    from          'no-reply@' + domain
    reply_to      profile_recipients(sender)
    subject       _('[ESCAMBO] Vocẽ tem uma nova mensagem!')
    content_type  'text/html'
    body :recipient => recipient,
         :sender => sender,
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
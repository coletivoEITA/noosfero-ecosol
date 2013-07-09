class ExchangePlugin::Mailer < Noosfero::Plugin::MailerBase

  def start_exchange_notification target, origin, exchange_id
    environment = origin.environment
    recipients    profile_recipients(target)
    from          "#{origin.name} <#{environment.contact_email}>"
    reply_to      profile_recipients(origin)
    subject       _('[%{environment}] You have a new proposal of exchange!') % {:environment => environment}
    content_type  'text/html'
    body :target => target,
         :origin => origin,
         :exchange_id => exchange_id
  end

  def new_proposal_notification target, origin, exchange_id, proposal_id
    environment = origin.environment
    recipients    profile_recipients(target)
    from          "#{origin.name} <#{environment.contact_email}>"
    reply_to      profile_recipients(origin)
    subject       _('[%{environment}] You have a new proposal of exchange!') % {:environment => environment}
    content_type  'text/html'
    body :target => target,
         :origin => origin,
         :exchange_id => exchange_id,
         :proposal_id => proposal_id
    
  end

  def new_message_notification sender, recipient, exchange_id
    environment = sender.environment
    recipients    profile_recipients(recipient)
    from          "#{sender.name} <#{environment.contact_email}>"
    reply_to      profile_recipients(sender)
    subject       _('[%{environment}] You have a new exchange message!') % {:environment => environment}
    content_type  'text/html'
    body :recipient => recipient,
         :sender => sender,
         :exchange_id => exchange_id
  end

  protected

  def url_for(options = {})
    options ||= {}
    url = case options
    when Hash
      options[:only_path] = false;
    end
    super options
  end

  def profile_recipients profile
    if profile.person?
      profile.contact_email
    else
      profile.admins.map{ |p| p.contact_email }
    end
  end

end

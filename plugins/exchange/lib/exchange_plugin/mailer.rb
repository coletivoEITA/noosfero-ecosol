class ExchangePlugin::Mailer < Noosfero::Plugin::MailerBase

  def start_exchange_notification target, origin, exchange_id
    self.environment = origin.environment
    @target = target
    @origin = origin
    @exchange_id = exchange_id

    mail to: profile_recipients(target),
      from: "#{origin.name} <#{environment.noreply_email}>",
      reply_to: profile_recipients(origin),
      subject:  _('[%{environment}] You have a new proposal of exchange!') % {environment: environment}
  end

  def new_proposal_notification target, origin, exchange_id, proposal_id
    self.environment = origin.environment
    @target = target
    @origin = origin
    @exchange_id = exchange_id
    @proposal_id = proposal_id

    mail to: profile_recipients(target),
      from: "#{origin.name} <#{environment.noreply_email}>",
      reply_to: profile_recipients(origin),
      subject:  _('[%{environment}] You have a new proposal of exchange!') % {environment: environment}
  end

  def new_message_notification sender, recipient, exchange_id
    self.environment = sender.environment
    @recipient = recipient
    @sender = sender
    @exchange_id = exchange_id

    mail to: profile_recipients(recipient),
      from: "#{sender.name} <#{environment.noreply_email}>",
      reply_to: profile_recipients(sender),
      subject:  _('[%{environment}] You have a new exchange message!') % {environment: environment}
  end

  protected

  def url_for options = {}
    options ||= {}
    url = case options
    when Hash
      options[:only_path] = false
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

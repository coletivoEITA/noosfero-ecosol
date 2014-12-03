class OrdersCyclePlugin::Mailer < Noosfero::Plugin::MailerBase

  include OrdersCyclePlugin::TranslationHelper

  helper ApplicationHelper
  helper OrdersCyclePlugin::TranslationHelper

  attr_accessor :environment
  attr_accessor :profile

  def message_to_supplier profile, supplier, subject, message
    self.environment = profile.environment
    @profile = profile
    @supplier = supplier
    @message = message

    mail to: profile_recipients(@supplier),
      from: environment.noreply_email,
      reply_to: profile_recipients(@profile),
      subject: t('lib.mailer.profile_subject') % {profile: profile.name, subject: subject}
  end

  def message_to_admins profile, member, subject, message
    self.environment = profile.environment
    @profile = profile
    @member = member
    @message = message

    mail to: profile_recipients(@member),
      from: environment.noreply_email,
      reply_to: profile_recipients(@profile),
      subject: t('lib.mailer.profile_subject') % {profile: profile.name, subject: subject}
  end

  def open_cycle profile, cycle, subject, message
    self.environment = profile.environment
    @profile = profile
    @cycle = cycle
    @message = message

    mail bcc: organization_members(@profile),
      from: environment.noreply_email,
      reply_to: profile_recipients(@profile),
      subject: t('lib.mailer.profile_subject') % {profile: profile.name, subject: subject}
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

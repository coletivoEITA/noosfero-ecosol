if ENV['MAIL_QUEUER']

  Mail::Message.include MailQueuer if ENV['MAIL_QUEUER']

end

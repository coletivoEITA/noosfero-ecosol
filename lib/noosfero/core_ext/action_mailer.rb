class ActionMailer::Base

  attr_accessor :environment

  # Set default host automatically if environment is set
  def url_for options = {}
    options[:host] ||= environment.default_hostname if self.environment
    super
  end

end

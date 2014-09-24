class ActionMailer::Base

  attr_accessor :environment

  # Set default host automatically if environment is set
  def url_for options = {}
    options[:host] ||= environment.default_hostname if self.environment
    super
  end

  def premailer_html html
    premailer = Premailer.new html.to_s, :with_html_string => true
    premailer.to_inline_css
  end

  def render_with_premailer *args
    premailer_html render_without_premailer(*args)
  end
  alias_method_chain :render, :premailer

end

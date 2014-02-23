class ActionMailer::Base

  attr_accessor :environment

  # Monkey patch to:
  # 1) Allow multiple render calls, by keeping the body assigns into an instance variable
  # 2) Don't render layout for partials
  def render opts
    @assigns ||= opts.delete(:body)
    if opts[:file] && (opts[:file] !~ /\// && !opts[:file].respond_to?(:render))
      opts[:file] = "#{mailer_name}/#{opts[:file]}"
    end

    begin
      old_template, @template = @template, initialize_template_class(@assigns)
      layout = respond_to?(:pick_layout, true) ? pick_layout(opts) : false unless opts[:partial]
      @template.render(opts.merge(:layout => layout))
    ensure
      @template = old_template
    end
  end

  # Set default host automatically if environment is set
  def url_for_with_host options = nil
    options[:host] ||= environment.default_hostname if self.environment
    url_for_without_host options
  end
  alias_method_chain :url_for, :host

  def premailer_html html
    premailer = Premailer.new html, :with_html_string => true
    premailer.to_inline_css
  end

  def render_with_premailer *args
    premailer_html render_without_premailer(*args)
  end
  alias_method_chain :render, :premailer

end

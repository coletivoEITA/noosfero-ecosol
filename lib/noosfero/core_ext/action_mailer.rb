class ActionMailer::Base

  attr_accessor :environment

  # Monkey patch to:
  # 1) Allow multiple render calls, by keeping the body assigns into an instance variable
  # 2) Don't render layout for partials
  def render opts={}
    @assigns ||= opts.delete(:body)
    if opts[:file] && (opts[:file] !~ /\// && !opts[:file].respond_to?(:render))
      opts[:file] = "#{mailer_name}/#{opts[:file]}"
    end

    begin
      old_template, @template = @template, initialize_template_class(@assigns || {})
      unless opts[:partial]
        layout = respond_to?(:pick_layout, true) ? pick_layout(opts) : false
        opts.merge! :layout => layout
      end
      @template.render opts
    ensure
      @template = old_template
    end
  end

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

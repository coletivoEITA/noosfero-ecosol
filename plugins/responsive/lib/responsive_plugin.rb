raise "Responsive plugins requires ruby 2.0's prepend for sane monkey patches" if RUBY_VERSION < '2.0'

class ResponsivePlugin < Noosfero::Plugin

  def self.plugin_name
    "Responsive"
  end

  def self.plugin_description
    _("Responsive layout for Noosfero")
  end

  def stylesheet?
    true
  end

  def js_files
    %w[bootstrap responsive-noosfero].map{ |j| "javascripts/#{j}" }
  end

  def head_ending
    '<meta name="viewport" content="width=device-width, initial-scale=1">'
  end

  def body_ending
    lambda do
      render 'layouts/modal'
    end
  end

end


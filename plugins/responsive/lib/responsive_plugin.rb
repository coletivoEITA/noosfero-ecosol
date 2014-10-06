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
    ['bootstrap.js', 'application_v3.js', 'responsive-noosfero.js'].map{ |j| "javascripts/#{j}" }
  end

end

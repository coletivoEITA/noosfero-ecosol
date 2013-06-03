require_dependency "#{File.dirname __FILE__}/ext/product"

class ExchangePlugin < Noosfero::Plugin

  def self.plugin_name
    "ExchangePlugin"
  end

  def self.plugin_description
    _("A plugin that implement an exchange system inside noosfero.")
  end

  def control_panel_buttons
    if context.profile.enterprise?
      { :title => _('My Exchanges'), :icon => 'exchange', :url => {:controller => 'exchange_plugin_myprofile', :action => 'index'} }
    end
  end

  def stylesheet?
    true
  end

end

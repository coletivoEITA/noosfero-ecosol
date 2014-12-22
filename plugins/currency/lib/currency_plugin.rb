
class CurrencyPlugin < Noosfero::Plugin

  def self.plugin_name
    "Currency"
  end

  def self.plugin_description
    _("Create and accepts social currencies")
  end

  def control_panel_buttons
    #if context.profile.enterprise?
      #{ title: _("My currencies"), url: {controller: 'currency_plugin_myprofile', action: 'edit'} }
    #end
  end

  def stylesheet?
    true
  end

  def js_files
    ['currency.js'].map{ |j| "javascripts/#{j}" }
  end

end

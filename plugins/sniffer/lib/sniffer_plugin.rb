require_dependency "#{File.dirname __FILE__}/ext/enterprise"
require_dependency "#{File.dirname __FILE__}/ext/product"
require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/article"

class SnifferPlugin < Noosfero::Plugin

  def self.plugin_name
    "Sniffer"
  end

  def self.plugin_description
    _("Sniffs opportunities ...")
  end

  def control_panel_buttons
    buttons = [{ :title => _("Enable Buyer Interests"), :icon => 'buyer-interests', :url => {:controller => 'sniffer_plugin_myprofile', :action => 'edit'} }]
    buttons.push( { :title => _("Opportunities Sniffer"), :icon => 'sniff-opportunities', :url => {:controller => 'sniffer_plugin_myprofile', :action => 'search'} } ) if context.profile.enterprise?
    buttons
  end

  def stylesheet?
    true
  end

  def js_files
    ['sniffer.js']
  end

  def profile_blocks(profile)
    SnifferPlugin::InterestsBlock
  end

  def environment_blocks(environment)
    SnifferPlugin::InterestsBlock
  end

end


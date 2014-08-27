# WORKAROUND: plugin class don't scope subclasses causing core classes conflict
class SnifferPlugin < Noosfero::Plugin; end

require_dependency "#{File.dirname __FILE__}/ext/noosfero/plugin"

class SnifferPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Opportunities sniffer")
  end

  def self.plugin_description
    _("Finds potencial suppliers and consumers of a enterprise")
  end

  def stylesheet?
    true
  end

  def js_files
    ['underscore-min.js', 'sniffer.js'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    buttons = [{ :title => _("Consumer Interests"), :icon => 'consumer-interests', :url => {:controller => 'sniffer_plugin_myprofile', :action => 'edit'} }]
    buttons.push( { :title => _("Opportunities Sniffer"), :icon => 'sniff-opportunities', :url => {:controller => 'sniffer_plugin_myprofile', :action => 'search'} } ) if context.profile.enterprise?
    buttons
  end

  def profile_blocks profile
    SnifferPlugin::InterestsBlock
  end

  def environment_blocks environment
    SnifferPlugin::InterestsBlock
  end

end

# solr indexed models needs to be loaded
if $0 =~ /rake$/ and defined? SolrPlugin and ActiveRecord::Base.connection.table_exists? "sniffer_plugin_opportunities"
  require_dependency "#{File.dirname __FILE__}/../models/sniffer_plugin/opportunity"
end


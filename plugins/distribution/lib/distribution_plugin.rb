
class DistributionPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('distribution_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('distribution_plugin.lib.plugin.description')
  end

  def profile_blocks profile
    DistributionPlugin::OrderBlock if DistributionPlugin::OrderBlock.available_for? profile
  end

  def control_panel_buttons
    profile = context.profile
    return nil unless profile.community?
    node = DistributionPlugin::Node.find_or_create(profile)
    { :title => I18n.t('distribution_plugin.lib.settings_solidary_dis'), :icon => 'distribution-solidary-network', :url => {:controller => :distribution_plugin_node, :profile => profile.identifier, :action => :settings} }
  end

end


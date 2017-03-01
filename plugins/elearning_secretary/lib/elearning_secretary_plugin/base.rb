class ElearningSecretaryPlugin::Base < Noosfero::Plugin

  def control_panel_buttons
    profile = context.profile
    return unless profile.community?
    [
      {title: I18n.t('elearning_secretary_plugin.views.control_panel'), icon: 'elearning-secretary-manage',
       url: {controller: 'elearning_secretary_plugin/manage', action: :index}},
    ]
  end


end

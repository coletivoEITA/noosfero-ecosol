class NetworksPlugin::Network < NetworksPlugin::BaseNode

  before_destroy :destroy_dependent

  def control_panel_settings_button
    {:title => I18n.t('networks_plugin.models.network.settings_button'), :icon => 'edit-profile-enterprise'}
  end

  def network?
    true
  end

  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

  def destroy_dependent
    self.as_parent_relations.each do |relation|
      relation.child.destroy!
      relation.destroy!
    end
    self.suppliers.each do |supplier|
      # also destroys the associated dummy profile
      supplier.destroy!
    end
  end

end

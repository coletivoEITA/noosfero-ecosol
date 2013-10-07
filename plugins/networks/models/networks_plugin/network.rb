class NetworksPlugin::Network < NetworksPlugin::BaseNode


  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

end

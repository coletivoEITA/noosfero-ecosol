module NetworksPlugin::SearchHelper

  protected

  def asset_class asset
    if asset == :networks
      NetworksPlugin::Network
    else
      asset.to_s.singularize.camelize.constantize
    end
  end

end

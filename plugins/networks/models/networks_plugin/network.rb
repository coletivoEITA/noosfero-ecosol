class NetworksPlugin::Network < Organization

  # this should be on Organization class, as they are declared there
  settings_items :zip_code, :city, :state, :country

end

require_dependency 'organization'

class Organization

  # this should be on Organization class, as they are declared there
  settings_items :business_name, :zip_code, :city, :state, :country

end

module SnifferPlugin::Helper

  include Noosfero::GeoRef

  def distance_between_profiles(source, target)
    Math.sqrt(
      # TODO: lat and lng must return 0 when null
      (KM_LAT * ((target.lat || 0) - (source.lat || 0)))**2 +
      (KM_LNG * ((target.lng || 0) - (source.lng || 0)))**2
    )
  end

end

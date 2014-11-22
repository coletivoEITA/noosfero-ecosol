require_dependency 'enterprise'
require_dependency "#{File.dirname __FILE__}/profile"

class Enterprise

  Metadata = Metadata.merge({
    'og:type' => "#{MetadataPlugin.og_type_namespace}:#{MetadataPlugin.og_types[:enterprise]}",
	  'business:contact_data:email' => proc{ |e| e.contact_email },
	  'business:contact_data:phone_number' => proc{ |e| e.contact_phone },
	  'business:contact_data:street_address' => proc{ |e| e.address },
	  'business:contact_data:locality' => proc{ |e| e.city },
	  'business:contact_data:region' => proc{ |e| e.state },
	  'business:contact_data:postal_code' => proc{ |e| e.zip_code },
	  'business:contact_data:country_name' => proc{ |e| e.country },
	  'place:location:latitude' => proc{ |p| p.lat },
	  'place:location:longitude' => proc{ |p| p.lng },
  })
end

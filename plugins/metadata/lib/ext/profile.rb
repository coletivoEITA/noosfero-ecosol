require_dependency 'profile'

class Profile

  Metadata = {
    'og:type' => "#{MetadataPlugin.og_type_namespace}:#{MetadataPlugin.og_types[:profile]}",
    'og:image' => proc{ |p| p.image.public_filename if p.image },
	  'og:title' => proc{ |p| p.short_name nil },
    'og:url' => proc{ |p| Noosfero::Application.routes.url_helpers.url_for p.url.except(:port) },
	  'og:description' => "",
	  'og:site_name' => "",
	  'og:updated_time' => proc{ |p| p.updated_at.iso8601 },
	  'og:see_also' => "",
	  'og:rich_attachment' => "",
	  'place:location:latitude' => proc{ |p| p.lat },
	  'place:location:longitude' => proc{ |p| p.lng },
    'og:locale:locale' => proc{ |p| p.environment.default_language },
    'og:locale:alternate' => proc{ |p| p.environment.languages - [p.environment.default_language] },
  }

end

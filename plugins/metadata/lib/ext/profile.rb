require_dependency 'profile'

class Profile

  Metadata = {
    'og:type' => "#{MetadataPlugin.og_type_namespace}:#{MetadataPlugin.og_types[:profile]}",
    'og:image' => proc{ |p, c| "#{p.environment.top_url}#{p.image.public_filename}" if p.image },
	  'og:title' => proc{ |p, c| p.short_name nil },
    'og:url' => proc{ |p, c| c.og_url_for p.url },
	  'og:description' => "",
	  'og:site_name' => "",
	  'og:updated_time' => proc{ |p, c| p.updated_at.iso8601 },
	  'og:see_also' => "",
	  'og:rich_attachment' => "",
	  'place:location:latitude' => proc{ |p, c| p.lat },
	  'place:location:longitude' => proc{ |p, c| p.lng },
    'og:locale:locale' => proc{ |p, c| p.environment.default_language },
    'og:locale:alternate' => proc{ |p, c| p.environment.languages - [p.environment.default_language] },
  }

end

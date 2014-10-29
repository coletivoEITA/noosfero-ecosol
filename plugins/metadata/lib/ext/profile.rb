require_dependency 'profile'

class Profile

  Metadata = {
    'og:type' => "#{MetadataPlugin.og_type_namespace}:profile",
    'og:url' => proc{ |p| Noosfero::Application.routes.url_helpers.url_for p.url.except(:port) },
    'og:locale:locale' => proc{ |p| p.environment.default_language },
    'og:locale:alternate' => proc{ |p| p.environment.languages - [p.environment.default_language] },
  }

end

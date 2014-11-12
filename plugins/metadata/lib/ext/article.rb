require_dependency 'article'

class Article

  Metadata = {
    'og:type' => "#{MetadataPlugin.og_type_namespace}:#{MetadataPlugin.og_types[:article]}",
    'og:url' => proc{ |p| Noosfero::Application.routes.url_helpers.url_for p.url.except(:port) },
    'og:title' => proc{ |a| a.title },
    'og:description' => proc{ |a| ActionView::Base.full_sanitizer.sanitize a.body },
    'og:image' => proc{ |a| a.body_images_paths },
    'og:see_also' => [],
    'og:site_name' => proc{ |a| a.profile.name },
    'og:updated_time' => proc{ |p| p.updated_at.iso8601 },
    'og:locale:locale' => proc{ |p| p.environment.default_language },
    'og:locale:alternate' => proc{ |p| p.environment.languages - [p.environment.default_language] },
    'twitter:image' => proc{ |a| a.body_images_paths },
    'article:published_time' => proc{ |a| a.published_at.iso8601 },
  }

end

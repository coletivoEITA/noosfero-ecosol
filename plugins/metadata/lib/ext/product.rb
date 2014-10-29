require_dependency 'product'

class Product

  Metadata = {
    'og:type' => "#{MetadataPlugin.og_type_namespace}:sse_product",
    'og:url' => proc{ |p| Noosfero::Application.routes.url_helpers.url_for p.url.except(:port) },
    'og:title' => proc{ |p| p.name },
    'og:description' => proc{ |p| ActionView::Base.full_sanitizer.sanitize p.description },
    'og:image' => proc{ |p| p.image.public_filename if p.image },
    'og:image:url' => proc{ |p| p.image.public_filename if p.image },
    'og:image:type' => proc{ |p| p.image.content_type if p.image },
    'og:image:height' => proc{ |p| p.image.height if p.image },
    'og:image:width' => proc{ |p| p.image.width if p.image },
    'og:see_also' => [],
    'og:site_name' => proc{ |p| Noosfero::Application.routes.url_helpers.url_for p.profile.url.except(:port) },
    'og:updated_time' => proc{ |p| p.updated_at.iso8601 },
    'og:locale:locale' => proc{ |p| p.environment.default_language },
    'og:locale:alternate' => proc{ |p| p.environment.languages - [p.environment.default_language] },
  }

  protected

end

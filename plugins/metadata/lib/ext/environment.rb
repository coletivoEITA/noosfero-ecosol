require_dependency 'environment'

class Environment

  Metadata = {
    'og:site_name' => proc{ |e| e.name },
    'og:description' => proc{ |e| e.name },
    'og:url' => proc{ |e| e.top_url },
    'og:locale:locale' => proc{ |e| e.default_language },
    'og:locale:alternate' => proc{ |e| e.languages - [e.default_language] }
  }

end

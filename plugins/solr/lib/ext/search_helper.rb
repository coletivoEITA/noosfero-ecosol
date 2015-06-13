require_dependency 'search_helper'

module SearchHelper

  FILTERS_OPTIONS_TRANSLATION.merge! order: {
    'more_recent' => _('More recent'),
    'relevance' => _('Relevance'),
    'closest' => _('Closest'),
  }

end


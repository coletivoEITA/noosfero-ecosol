module PaginationHelper

  def pagination_links(collection, options={})
    options = {:previous_label => content_tag(:span, '&laquo; ', :class => 'previous-arrow') + _('Previous'), :next_label => _('Next') + content_tag(:span, ' &raquo;', :class => 'next-arrow'), :inner_window => 1, :outer_window => 0 }.merge(options)
    will_paginate(collection, options)
  end

end

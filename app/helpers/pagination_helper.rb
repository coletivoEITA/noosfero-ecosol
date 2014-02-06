module PaginationHelper

  def pagination_links collection, options={}
    options = {:previous_label => '&laquo; ' + _('Previous'), :next_label => _('Next') + ' &raquo;'}.merge(options)
    will_paginate collection, options
  end

end

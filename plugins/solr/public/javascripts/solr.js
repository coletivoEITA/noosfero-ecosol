solr = {

  facets: {

    more_or_less: function (context, url) {
      context = $(context)
      var wrap = context.parents('.facet-menu-wrap')
      var menu = context.parents('.facet-menu')

      if (menu.hasClass('less') && wrap.find('.facet-menu.more').length == 0) {
        $.get(url, function(data) {
          wrap.append($(data).find('.facet-menu'))
          wrap.find('.facet-menu.less').hide()
        })
      } else {
        wrap.find('.facet-menu').toggle()
      }
    },
  },

}

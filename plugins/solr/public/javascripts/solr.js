solr = {

  facets: {

    more: function (context, url) {
      var results = jQuery(context).parents('.facet-menu')
      jQuery.get(url, function(data) {
        jQuery(results).replaceWith(data)
      })
    },
  },

}

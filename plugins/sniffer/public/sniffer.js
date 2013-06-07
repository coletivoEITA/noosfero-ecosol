sniffer = {

  map: {

    markerIndex: [],
    markerList: [],
    filters: [],

    resize: function () {
      var wrap = jQuery('#sniffer-search-wrap');
      wrap.css('height', jQuery(window).height() - wrap.offset().top);

      var map = jQuery('#map');
      legend = jQuery('#legend-wrap-1');
      map.css('height', wrap.outerHeight() - legend.outerHeight(true));
    },

    load: function (options) {
      jQuery(window).load(sniffer.map.resize);
      jQuery(window).resize(sniffer.map.resize);
      mapLoad(options.zoom);

      var profile = options.profile;
      var homeIcon = "/plugins/sniffer/images/marker_home.png";
      var suppliersIcon = "/plugins/sniffer/images/marker_suppliers.png";
      var consumersIcon = "/plugins/sniffer/images/marker_consumers.png";
      var bothIcon = "/plugins/sniffer/images/marker_both.png";

      _.each(options.mapData, function (data) {
        var profile = data.profile;
        var data = data.data;
        var sp = data.suppliers_products;
        var cp = data.consumers_products;

        var icon = null;
        if (_.size(sp) > 0 && _.size(cp) > 0)
          icon = bothIcon;
        else if (_.size(sp) > 0)
          icon = suppliersIcon;
        else
          icon = consumersIcon;

        var marker = mapPutMarker(profile.lat, profile.lng, profile.name, icon, sniffer.map.fillBalloon);
        marker.balloonUrl = options.balloonUrl.replace('_id_', profile.id);
        marker.balloonData = data;
        marker.profile = profile;
        marker.distance = profile.distance;
        marker.inListElement = jQuery("#sniffer-plugin-profile-"+profile.id);

        _.each(_.extend(sp, cp), function (p) {
          if (sniffer.map.markerIndex[p.product_category_id] == undefined)
            sniffer.map.markerIndex[p.product_category_id] = [];

          sniffer.map.markerIndex[p.product_category_id].push(marker);
        });

        sniffer.map.markerList.push(marker);
      });

      var marker = mapPutMarker(profile.lat, profile.lng, profile.name, homeIcon, options.myBalloonUrl);
      sniffer.map.filter();

      mapCenter();
    },

    fillBalloon: function (marker) {
      if (marker.cachedData)
        mapOpenBalloon(marker, marker.cachedData);
      else
        jQuery.post(marker.balloonUrl, marker.balloonData, function (data) {
          marker.cachedData = jQuery(data).html();
          mapOpenBalloon(marker, marker.cachedData);
        });
    },

    matchCategoryFilters: function (marker) {
      var match = true;
      jQuery.each(sniffer.map.filters, function (index, id) {
        if (sniffer.map.markerIndex[id].indexOf(marker) == -1)
        match = false;
      });
      return match;
    },

    filter: function () {
      jQuery.each(sniffer.map.markerList, function(index, marker) {
        var visible = (!sniffer.map.filters.distance || sniffer.map.filters.distance >= marker.distance) && (sniffer.map.matchCategoryFilters(marker));
        marker.setVisible(visible);
        parent = visible ? '#sniffer-plugin-search-visible-list' : '#sniffer-plugin-search-invisible-list'
        jQuery(parent + ' .sniffer-plugin-results').hide().append(marker.inListElement).fadeIn();
      });

      toggleVisible = !jQuery('#sniffer-plugin-search-visible-list .sniffer-plugin-results').children().length;
      visibleNoResults = jQuery('#sniffer-plugin-search-visible-list .no-results');
      if (toggleVisible)
        visibleNoResults.hide().fadeIn();
      else
        visibleNoResults.hide();
      jQuery('#sniffer-plugin-search-invisible-list .no-results').hide().toggle(!jQuery('#sniffer-plugin-search-invisible-list .sniffer-plugin-results').children().length);
    },

    applyCategoryFilter: function (id) {
      sniffer.map.filters.push(id);
      sniffer.map.filter();
    },

    unapplyCategoryFilter: function (id) {
      sniffer.map.filters.pop(id);
      sniffer.map.filter();
    },

    maxDistance: function (distance) {
      distance = parseInt(distance);
      sniffer.map.filters.distance = distance > 0 ? distance : undefined;
      sniffer.map.filter();
    },

    showProfile: function (id) {
      jQuery.each(sniffer.map.markerList, function(index, marker) {
        if (marker.profile.id == id)
        sniffer.map.fillBalloon(marker);
      });
    },
  },
}

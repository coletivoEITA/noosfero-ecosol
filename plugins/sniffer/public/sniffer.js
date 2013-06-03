function sniffer_plugin_interest_enable(enabled) {
  el = jQuery('#sniffer-plugin-product-select');
  el.toggleClass('disabled', !enabled);

  margin = 10;
  return jQuery('#sniffer-plugin-disable-pane').css({
    top: el.position().top - margin,
    left: el.position().left - margin,
    width: el.innerWidth() + margin*2,
    height: el.innerHeight() + margin*2,
  }).toggle(!enabled);
}

function sniffer_plugin_show_hide_toggle(context, hideText, showText, element) {
  isShow = (jQuery(context).text() == showText);
  element.fadeToggle();
  jQuery(context).text(isShow ? hideText : showText);
}

sniffer = {

  map: {

    markerIndex: [],
    markerList: [],

    resize: function () {
      wrap = jQuery('#sniffer-search-wrap');
      wrap.css('height', jQuery(window).height() - wrap.offset().top);

      map = jQuery('#map');
      legend = jQuery('#legend-wrap-1');
      map.css('height', wrap.height() - legend.outerHeight(true));
    },

    load: function (options) {
      jQuery(window).load(sniffer.map.resize);
      jQuery(window).resize(sniffer.map.resize);
      mapLoad(options.zoom);

      var profile = options.profile;
      var ltblueIcon = "http://www.google.com/intl/en_us/mapfiles/ms/micons/ltblue-dot.png";
      var greenIcon = "http://www.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png";
      var yellowIcon = "http://www.google.com/intl/en_us/mapfiles/ms/micons/yellow-dot.png";

      _.each(options.mapData, function (data, profile) {
        var sp = data['suppliers_products'];
        var bp = data['buyers_products'];

        var icon = null;
        if (_.size(sp) > 0 && _.size(bp) > 0)
          icon = yellowIcon;
        else if (_.size(sp) > 0)
          icon = greenIcon;
        else
          icon = ltblueIcon;

        var marker = mapPutMarker(profile.lat, profile.lng, profile.name, icon, sniffer.map.fillBalloon);
        marker.balloonUrl = options.balloonUrl.replace('<id>', profile.id);
        marker.balloonData = data.to_json;
        marker.profile = profile;
        marker.distance = profile.distance;
        marker.inListElement = jQuery("#sniffer-plugin-profile-"+profile.id);

        _each(_.extend(sp, bp), function (p) {
          if (sniffer.map.markerIndex[p.product_category_id] == undefined)
            sniffer.map.markerIndex[p.product_category_id] = [];

          sniffer.map.markerIndex[p.product_category_id].push(marker);
        });

        sniffer.map.markerList.push(marker);
      });

      var filters = [];
      var marker = mapPutMarker(profile.lat, profile.lng, profile.name, null, options.myBalloonUrl);
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
      jQuery.each(filters, function (index, id) {
        if (sniffer.map.markerIndex[id].indexOf(marker) == -1)
        match = false;
      });
      return match;
    },

    filter: function () {
      jQuery.each(sniffer.map.markerList, function(index, marker) {
        var visible = (!filters.distance || filters.distance >= marker.distance) && (sniffer.map.matchCategoryFilters(marker));
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
      filters.push(id);
      sniffer.map.filter();
    },

    unapplyCategoryFilter: function (id) {
      filters.pop(id);
      sniffer.map.filter();
    },

    maxDistance: function (distance) {
      distance = parseInt(distance);
      filters.distance = distance > 0 ? distance : undefined;
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

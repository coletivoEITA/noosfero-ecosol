sniffer = {

  search: {

    filters: [],

    showFilters: function () {
      jQuery('#product-search .focus-pane').show();
    },
    hideFilters: function () {
      jQuery('#product-search .focus-pane').hide();
    },

    filter: function () {
      jQuery.each(sniffer.search.map.markerList, function(index, marker) {
        var visible = (!sniffer.search.filters.distance || sniffer.search.filters.distance >= marker.distance) && (sniffer.search.matchCategoryFilters(marker));
        marker.setVisible(visible);
      });
    },
    matchCategoryFilters: function (marker) {
      var match = false;
      jQuery.each(sniffer.search.filters, function (index, id) {
        if (sniffer.search.map.markerIndex[id].indexOf(marker) != -1)
          match = true;
      });
      return match;
    },

    toggleCategoryFilter: function (input) {
      var id = parseInt(jQuery(input).attr('name'));
      if (input.checked)
        sniffer.search.applyCategoryFilter(id);
      else
        sniffer.search.unapplyCategoryFilter(id);
    },
    applyCategoryFilter: function (id) {
      sniffer.search.filters.push(id);
      sniffer.search.filter();
    },
    unapplyCategoryFilter: function (id) {
      sniffer.search.filters.pop(id);
      sniffer.search.filter();
    },

    maxDistance: function (distance) {
      distance = parseInt(distance);
      sniffer.search.filters.distance = distance > 0 ? distance : undefined;
      sniffer.search.filter();
    },

    map: {

      markerIndex: [],
      markerList: [],

      //openBalloon: mapOpenBalloon,
      openBalloon: function (marker, html) {
        infoBox = new InfoBox({boxStyle: {width: null}, closeBoxURL: ""});
        InfoBox.prototype.addClickHandler_ = function () {
          closeBox = jQuery('#close-box')[0];
          this.closeListener_ = google.maps.event.addDomListener(closeBox, 'click', this.getCloseClickHandler_());
        }
        infoBox.setPosition(marker.getPosition());
        infoBox.setContent(html);
        infoBox.open(map, marker);
      },

      resize: function () {
        var wrap = jQuery('#sniffer-search-wrap');
        wrap.css('height', jQuery(window).height() - wrap.offset().top);

        var map = jQuery('#map');
        legend = jQuery('#legend-wrap-1');
        map.css('height', wrap.outerHeight() - legend.outerHeight(true));
      },

      load: function (options) {
        jQuery(window).load(sniffer.search.map.resize);
        jQuery(window).resize(sniffer.search.map.resize);
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

          var marker = mapPutMarker(profile.lat, profile.lng, profile.name, icon, sniffer.search.map.fillBalloon);
          marker.balloonUrl = options.balloonUrl.replace('_id_', profile.id);
          marker.balloonData = data;
          marker.profile = profile;
          marker.distance = profile.distance;

          _.each(_.union(sp, cp), function (p) {
            if (sniffer.search.map.markerIndex[p.product_category_id] == undefined)
              sniffer.search.map.markerIndex[p.product_category_id] = [];

            sniffer.search.map.markerIndex[p.product_category_id].push(marker);
            sniffer.search.filters.push(p.product_category_id);
          });

          sniffer.search.map.markerList.push(marker);
        });

        var marker = mapPutMarker(profile.lat, profile.lng, profile.name, homeIcon, options.myBalloonUrl);
        sniffer.search.filter();

        mapCenter();
      },

      fillBalloon: function (marker) {
        if (marker.cachedData)
          sniffer.search.map.openBalloon(marker, marker.cachedData);
        else
          jQuery.post(marker.balloonUrl, marker.balloonData, function (data) {
            marker.cachedData = jQuery(data).html();
            sniffer.search.map.openBalloon(marker, marker.cachedData);
          });
      },

      showProfile: function (id) {
        jQuery.each(sniffer.search.markerList, function(index, marker) {
          if (marker.profile.id == id)
          sniffer.search.fillBalloon(marker);
        });
      },
    },
  },
}

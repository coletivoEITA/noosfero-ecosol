// underscore use of <@ instead of <%
_.templateSettings = {
  interpolate: /\<\@\=(.+?)\@\>/gim,
  evaluate: /\<\@(.+?)\@\>/gim
};

// from http://stackoverflow.com/questions/17033397/javascript-strings-with-keyword-parameters
String.prototype.format = function(obj) {
  return this.replace(/%\{([^}]+)\}/g,function(_,k){ return obj[k] });
};

sniffer = {

  search: {

    filters: [],

    load_search_input: function (options) {
      var input = jQuery(".sniffer-search-input");
      input.hint();
      input.autocomplete({
        source: options.sourceUrl,
        select: function (event, ui) {
          category = {id: ui.item.value, name: ui.item.label};
          sniffer.search.category.append([category]);

          url = options.addUrl.replace('_id_', category.id);
          jQuery.post(url, function (data) { eval(data); });

          input.val('');
          return false;
        },
      });
    },

    showFilters: function () {
      jQuery('#product-search .focus-pane').show();
    },
    hideFilters: function () {
      jQuery('#product-search .focus-pane').hide();
    },

    filter: function () {
      jQuery.each(sniffer.search.map.markerList, function(index, marker) {
        var visible = (!sniffer.search.filters.distance || sniffer.search.filters.distance >= marker.profile.distance) && (sniffer.search.category.matchFilters(marker));
        marker.setVisible(visible);
      });
    },

    maxDistance: function (distance) {
      distance = parseInt(distance);
      sniffer.search.filters.distance = distance > 0 ? distance : undefined;
      sniffer.search.filter();
    },

    profile: {

      findMarker: function (id) {
        var marker;
        jQuery.each(sniffer.search.map.markerList, function(index, m) {
          if (m.profile.id == id)
            marker = m;
        });
        return marker;
      },

    },

    category: {

      matchFilters: function (marker) {
        var match = false;
        jQuery.each(sniffer.search.filters, function (index, id) {
          if (sniffer.search.map.markerIndex[id].indexOf(marker) != -1)
          match = true;
        });
        return match;
      },

      toggleFilter: function (input) {
        var id = parseInt(jQuery(input).attr('name'));
        if (input.checked)
          sniffer.search.category.applyFilter(id);
        else
          sniffer.search.category.unapplyFilter(id);
      },
      applyFilter: function (id) {
        sniffer.search.filters.push(id);
        sniffer.search.filter();
      },
      unapplyFilter: function (id) {
        sniffer.search.filters.pop(id);
        sniffer.search.filter();
      },

      exists: function (id) {
        var find = jQuery('#categories-table input[name='+id+']');
        find.length > 0;
      },

      template: function (categories) {
        var template = jQuery('#sniffer-category-add-template');
        return _.map(categories, function (category) {
          if (sniffer.search.category.exists(category.id)) return;
          return _.template(template.html(), {category: category});
        }).join('');
      },
      append: function (categories) {
        var target = jQuery('#categories-table');
        var template = sniffer.search.category.template(categories);
        target.append(template);
      },

    },

    map: {

      markerIndex: [],
      markerList: [],

      homeIcon: "/plugins/sniffer/images/marker_home.png",
      suppliersIcon: "/plugins/sniffer/images/marker_suppliers.png",
      consumersIcon: "/plugins/sniffer/images/marker_consumers.png",
      bothIcon: "/plugins/sniffer/images/marker_both.png",

      marker: {

        //create: mapPutMarker,
        create: function (lat, lng, title, icon, url_or_function) {
          var point_str = lat + ":" + lng;
          if (mapPoints[point_str]) {
            lng += (Math.random() - 0.5) * 0.02;
            lat += (Math.random() - 0.5) * 0.02;
          } else {
            mapPoints[point_str] = true;
          }

          var template = jQuery('#marker-template');
          var element = jQuery(_.template(template.html(), {icon: icon, title: title})).get(0);
          var point = new google.maps.LatLng(lat, lng);
          var marker = new CustomMarker({map: map, element: element, position: point});

          jQuery(marker.element).click(function() { url_or_function(marker); });
          mapBounds.extend(point);

          return marker;
        },

        add: function(profile, icon, filtered) {
          if (filtered == undefined)
            filtered = true;

          var marker = sniffer.search.profile.findMarker(profile.id);
          if (!marker)
            marker = sniffer.search.map.marker.create(profile.lat, profile.lng, profile.name, icon, sniffer.search.map.balloon.fill);
          marker.profile = profile;

          if (filtered)
            sniffer.search.map.markerList.push(marker);

          return marker;
        },

        index: function (product_category_id, marker) {
          if (sniffer.search.map.markerIndex[product_category_id] == undefined)
            sniffer.search.map.markerIndex[product_category_id] = [];

          sniffer.search.map.markerIndex[product_category_id].push(marker);
          sniffer.search.filters.push(product_category_id);
        },
      },

      balloon: {

        //open: mapOpenBalloon,
        open: function (marker, html) {
          infoBox = new InfoBox({boxStyle: {width: null}, closeBoxURL: ""});
          InfoBox.prototype.addClickHandler_ = function () {
            closeBox = jQuery('#close-box')[0];
            this.closeListener_ = google.maps.event.addDomListener(closeBox, 'click', this.getCloseClickHandler_());
          }
          infoBox.setPosition(marker.getPosition());
          infoBox.setContent(html);
          infoBox.open(map, marker);
        },

        fill: function (marker) {
          if (marker.cachedData)
            sniffer.search.map.balloon.open(marker, marker.cachedData);
          else
            jQuery.post(marker.profile.balloonUrl, marker.profile.balloonData, function (data) {
              marker.cachedData = jQuery(data).html();
              sniffer.search.map.balloon.open(marker, marker.cachedData);
            });
        },
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
        profile.balloonUrl = options.myBalloonUrl;
        var marker = sniffer.search.map.marker.add(profile, sniffer.search.map.homeIcon, false);

        _.each(options.mapData, function (data) {
          var profile = data.profile;
          var data = data.data;
          var sp = data.suppliers_products;
          var cp = data.consumers_products;

          var icon = null;
          if (_.size(sp) > 0 && _.size(cp) > 0)
            icon = sniffer.search.map.bothIcon;
          else if (_.size(sp) > 0)
            icon = sniffer.search.map.suppliersIcon;
          else
            icon = sniffer.search.map.consumersIcon;

          profile.balloonUrl = options.balloonUrl.replace('_id_', profile.id);
          profile.balloonData = data;
          var marker = sniffer.search.map.marker.add(profile, icon);

          _.each(_.union(sp, cp), function (p) {
            sniffer.search.map.marker.index(p.product_category_id, marker);
          });
        });

        sniffer.search.filter();
        mapCenter();
      },

    },
  },
};


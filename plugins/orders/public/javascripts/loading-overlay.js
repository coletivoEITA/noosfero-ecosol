if (typeof loading_overlay === 'undefined') {

  // block user actions while making a post. Also indicate the network transaction
  loading_overlay = {

    show: function (selector) {
      var element = jQuery(selector);
      var overlay = jQuery('<div>', {
        class: 'loading-overlay',
        css: {
          width: element.outerWidth(),
          height: element.outerHeight(),
          left: element.position().left,
          top: element.position().top,
          marginLeft: parseFloat(element.css('margin-left')),
          marginTop: parseFloat(element.css('margin-top')),
          marginRight: parseFloat(element.css('margin-right')),
          marginBottom: parseFloat(element.css('margin-bottom')),
        },
      }).appendTo(element).get(0);

      overlay.dest = element;
      element.loading_overlay = overlay;
    },

    hide: function (selector) {
      var element = jQuery(selector);
      var overlay = element.find('.loading-overlay');
      overlay.remove();
    },

  };

  // this action is going look for every form with data-loading attr and show the loading_overlay
  jQuery(function() {
    jQuery('form[data-loading]').on('ajax:before', function() {
      if (jQuery(this.data['loading']) == true)
        loading_overlay.show(jQuery(this));
      else
        loading_overlay.show(jQuery(this.data['loading']));
    });
    jQuery('form[data-loading]').on('ajax:complete', function() {
      if (jQuery(this.data['loading']) == true)
        loading_overlay.hide(jQuery(this));
      else
        loading_overlay.hide(jQuery(this.data['loading']));
    });
  });
}

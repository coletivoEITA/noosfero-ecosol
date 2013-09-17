if (typeof loading_overlay === 'undefined') {

// block user actions while making a post. Also indicate the network transaction
loading_overlay = {

  show: function (selector) {
    var element = jQuery(selector);
    var pos = {
      width: element.outerWidth(),
      height: element.outerHeight(),
      top: element.position().top,
      marginLeft: parseFloat(element.css('margin-left')),
      marginTop: parseFloat(element.css('margin-top')),
      marginRight: parseFloat(element.css('margin-right')),
      marginBottom: parseFloat(element.css('margin-bottom')),
    };

    var overlay = jQuery('<div>', {
      class: 'loading-overlay',
      css: {
        top: pos.top, left: pos.left,
        width: pos.width, height: pos.height,
        marginTop: pos.marginTop,
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

}

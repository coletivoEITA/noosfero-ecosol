if (typeof loading_overlay === 'undefined') {

// block user actions while making a post. Also indicate the network transaction
loading_overlay = {

  show: function (elementId) {
    element = jQuery("#"+elementId);
    var pos = {
      width: element.outerWidth(),
      height: element.outerHeight(),
      top: element.position().top + parseFloat(element.css('margin-top')),
      left: element.position().left + parseFloat(element.css('margin-left')),
    };

    jQuery('<div>', {
      id: elementId + '-overlay',
      class: 'loading-overlay',
      css: {
        top: pos.top, left: pos.left,
        width: pos.width, height: pos.height,
      },
    }).appendTo(element);
  },

  hide: function (element) {
    jQuery("#"+element+"-overlay").remove();
  },

};

}

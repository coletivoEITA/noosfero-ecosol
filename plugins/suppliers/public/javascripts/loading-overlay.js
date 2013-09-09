if (typeof loading === 'undefined') {

loading_overlay = {

  // block user actions while making a post. Also indicate the network transaction
  show: function (element) {
    var pos = jQuery.extend({
      width: jQuery("#"+element).outerWidth(),
      height: jQuery("#"+element).outerHeight(),
    }, jQuery("#"+element).position());

    jQuery('<div>', {
      id: element + '-overlay',
      class: 'loading-overlay',
      css: {
        top: pos.top, left: pos.left,
        width: pos.width, height: pos.height,
      },
    }).appendTo(jQuery("#"+element));
  },

  hide: function (element) {
    jQuery("#"+element+"-overlay").remove();
  },

};

}


consumers_coop = {

  toggle_header_color_area: function(t) {
    if (t.val() != 'pure_color') {
      jQuery('#consumers-coop-header-bg-color input').each(function(f){
        jQuery(this).disable();
      });
      jQuery('#consumers-coop-header-bg-color div.color-choose').each(function(f){
        jQuery(this).addClass('disabled');
      });
    }
    else {
      jQuery('#consumers-coop-header-bg-color input').each(function(f) {
        jQuery(this).enable();
      });
      jQuery('#consumers-coop-header-bg-color div.color-choose').each(function(f){
        jQuery(this).removeClass('disabled');
      });
    }
  },

};

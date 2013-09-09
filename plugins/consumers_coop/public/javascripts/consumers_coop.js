
consumers_coop = {

  toggle_header_color_area: function(t) {
    if (t.value != 'pure_color') {
      jQuery('#distribution-header-bg-color input').each(function(f){
        $(this).disable();
      });
      jQuery('#distribution-header-bg-color div.color-choose').each(function(f){
        $(this).addClassName('disabled');
      });
    }
    else {
      jQuery('#distribution-header-bg-color input').each(function(f) {
        $(this).enable();
      });
      jQuery('#distribution-header-bg-color div.color-choose').each(function(f){
        $(this).removeClassName('disabled');
      });
    }
  },

};

jQuery(function($){

  $(window).bind( 'hashchange', function(e) {
    var url = $.param.fragment();
    
    $('<div class=".loading"/>');

    $('.distribution-plugin-page').load(url, function() {
        $('.loading').hide();

        if (url && (match = $( 'a[href="#' + url + '"]' )).length > 0) {
          $('.distribution-plugin-menu-entry').removeClass('distribution-plugin-menu-selected');
          match.addClass('distribution-plugin-menu-selected');
        }
      });
  })

  // Since the event is only triggered when the hash changes, we need to trigger
  // the event now, to handle the hash the page may have loaded with.
  $(window).trigger('hashchange');
  
});

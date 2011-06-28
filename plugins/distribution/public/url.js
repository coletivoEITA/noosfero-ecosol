jQuery(function($){
  $(window).bind( 'hashchange', function(e) {
    var url = $.param.fragment();
    
    // Hide any visible ajax content.
    $( '.distribution-plugin-page' ).children().hide();

    $( '<div class=".loading"/>' );

    $( '<div class="distribution-plugin-page-body"/>' )
      .appendTo( '.distribution-plugin-page' )
      .load( url, function() {
        $( '.loading' ).hide();
      });
  })
  
  // Since the event is only triggered when the hash changes, we need to trigger
  // the event now, to handle the hash the page may have loaded with.
  $(window).trigger( 'hashchange' );
  
});

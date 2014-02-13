
pagination = {

  showMore: function(newPagination, appendFunction) {
    if (newPagination) {
      jQuery('.pagination').replaceWith(newPagination);
      jQuery('.pagination').addClass('infinite-scroll');
    } else
      jQuery('.pagination').remove();

    appendFunction();
  },

  // inspired by http://stackoverflow.com/questions/13555101/infinite-scroll-and-will-paginate-appending-the-next-page-of-items-multiple-ti
  infiniteScroll: function(text) {
    jQuery(function() {
      jQuery('.pagination').addClass('infinite-scroll');
    });

    jQuery(window).scroll(function () {
      // Bail out right away if we're busy loading the next chunk.
      if (window.pagination_loading)
        return;

      var url = jQuery('.pagination .next_page').attr('href')
      if (url && jQuery(window).scrollTop() > (jQuery('.pagination').offset().top - jQuery(window).height() - 50)) {

        jQuery('.pagination').html(
          jQuery('<div class=loading>').text(text)
        );

        window.pagination_loading = true
        jQuery.getScript(url).always(function() {
          window.pagination_loading = false
        });
      }
    });
  },

};

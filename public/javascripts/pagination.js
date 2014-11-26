
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
  infiniteScroll: function(text, options) {
    options = options || {};

    jQuery(function() {
      jQuery('.pagination').addClass('infinite-scroll');
    });

    jQuery(window).scroll(function () {
      // Bail out right away if we're busy loading the next chunk.
      if (pagination.loading)
        return;

      var url = jQuery('.pagination .next_page').attr('href')
      if (url && jQuery(window).scrollTop() > (jQuery('.pagination').offset().top - jQuery(window).height() - 50)) {

        jQuery('.pagination').html(
          jQuery('<div class=loading>').text(text)
        );

        pagination.loading = true

        if (options.load)
          options.load(url)
        else
          jQuery.getScript(url).always(function() {
            pagination.loading = false
          });
      }
    });
  },

};

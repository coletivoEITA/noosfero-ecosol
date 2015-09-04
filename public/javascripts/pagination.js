
pagination = {
  loading: false,

  showMore: function(newPagination, appendFunction) {
    if (newPagination) {
      $('.pagination').replaceWith(newPagination);
      $('.pagination').addClass('infinite-scroll');
    } else
      $('.pagination').remove();

    appendFunction();
  },

  click: function(callback) {
    $(document).on('click', '.pagination a', function(e) {
      e.preventDefault();
      if (callback)
        callback(e, this)
      else {
        // what to have as default?
      }
    });
  },

  // inspired by http://stackoverflow.com/questions/13555101/infinite-scroll-and-will-paginate-appending-the-next-page-of-items-multiple-ti
  infiniteScroll: function(text, options) {
    options = options || {};

    $(function() {
      $('.pagination').addClass('infinite-scroll');
    });

    $(window).scroll(function () {
      // Bail out right away if we're busy loading the next chunk.
      if (pagination.loading)
        return;

      var url = $('.pagination .next_page').attr('href')
      if (url && $(window).scrollTop() > ($('.pagination').offset().top - $(window).height() - 50)) {

        $('.pagination').html(
          $('<div class=loading>').text(text)
        );

        pagination.loading = true

        if (options.load)
          // don't forget to set pagination.loading to false!
          options.load(url)
        else
          $.getScript(url).always(function() {
            pagination.loading = false
          });
      }
    });
  },

};

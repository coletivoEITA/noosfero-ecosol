noosfero.modal = {

  el: function() {
    return jQuery('#noosferoModal')
  },
  content: function() {
    return jQuery('#noosferoModalContent')
  },

  watchClass: function() {
    jQuery(function($) {
      $(document).delegate('.modal-toggle', 'click', function() {
        noosfero.modal.content().empty().load($(this).attr('href'));
        noosfero.modal.el().modal();

        return false;
      });

      $(document).delegate('.modal-close', 'click', function() {
        noosfero.modal.close();
        return false;
      });
      return false;
    });
  },

  inline: function(href, options) {
    noosfero.modal.html(jQuery(href).html(), options)

    return false;
  },

  html: function(html, options) {
    noosfero.modal.content().html(html)
    noosfero.modal.el().modal(options)
  },

  close: function(){
    noosfero.modal.el().modal('hide');
  },

};

noosfero.modal.watchClass();


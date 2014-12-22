noosfero.form = {

  init: function() {
    $(document).on('submit', 'form.disable-on-submit', function() {
      $(this).find('input[type=submit]').prop('disabled', true).addClass('disabled')
    })
  },

}

noosfero.form.init();

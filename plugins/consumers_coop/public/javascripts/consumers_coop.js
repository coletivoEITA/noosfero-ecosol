
consumers_coop = {

  add_payment_method: function(e) {
    var i = e.target.options.selectedIndex
    var value = e.target.options[i].value
    e.target.options.selectedIndex = 0
    if ($('.payment_method_id-'+value).length > 0)
      return
    var text = e.target.options[i].text
    console.log(text)
    $('<span data="'+value+'">').append(text).append($('<span class=remove>').append('x')).appendTo('.chosen_payment_methods')
    console.log($('<span data="'+value+'">').append(text).append($('<span class=remove>').append('x')))

    $('<input name="profile_data[payment_method_ids][]" multiple="multiple" type="hidden" class="payment_method_id-'+value+'" value="'+value+'">').appendTo('.chosen_payment_methods')


  },
  remove_payment_method: function(e) {
    var slug = $(e.target).parent().attr('data')
    $('.payment_method_id-'+slug).remove()
    $(e.target).parent().remove()
  },

  set_payment_options: function() {
    jQuery('input[name="profile_data[consumers_coop_settings][payments_enabled]"]').on('click', function(e) {
      if ( $('#profile_data_consumers_coop_settings_payments_enabled_true').attr('checked') ) {
        $('.payment-methods').show();
      }
      if ( $('#profile_data_consumers_coop_settings_payments_enabled_false').attr('checked') ) {
        $('.payment-methods').hide();
      }
    });
    jQuery('#payment_methods').on('change', consumers_coop.add_payment_method);
    jQuery('.chosen_payment_methods').on('click', 'span.remove', consumers_coop.remove_payment_method);
  }
};

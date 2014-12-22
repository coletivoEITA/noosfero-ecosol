
delivery = {

  view_toggle: function () {
    if (jQuery('#delivery-method-edit').is(":visible"))
      jQuery('#delivery-method-edit form.edit_delivery_method').find('textarea, input[type=text]').val('');
    jQuery('#delivery-method-choose, #delivery-method-edit').toggle();
  },
  new_toggle: function() {
    jQuery('#delivery-method-choose, #delivery-method-new').toggle();
  }

};

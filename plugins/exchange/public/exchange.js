
exchange = {

  add_unregistered_item_show_form: function (enterprise) {
    var e = document.getElementById('exchange-add-money' + '-' + enterprise);
    e.className = 'action-button exchange-add-money-active'
      var e = document.getElementById('exchange-add-unreg-item' + '-' + enterprise);
    e.className = 'action-button exchange-add-unreg-item-active';
  },

  add_unregistered_item_hide_form: function (enterprise) {
    var e = document.getElementById('exchange-add-money' + '-' + enterprise);
    e.className = 'action-button exchange-add-money';
    var e = document.getElementById('exchange-add-unreg-item' + '-' + enterprise);
    e.className = 'action-button exchange-add-unreg-item';
  },
};

formSubmit = {
  submitingForm: null,

  disable: function (form, disable_text) {
    formSubmit.submitingForm = jQuery(form);
    var input = formSubmit.submitingForm.find(':submit');
    input.attr('originalValue', input.val());
    input.val(disable_text);
    input.attr('disabled', 'disabled');
  },
  enable: function (form) {
    var input = formSubmit.submitingForm.find(':submit');
    input.val(input.attr('originalValue'));
    input.attr('originalValue', '');
    input.attr('disabled', null);
    formSubmit.submitingForm = null;
  },
};

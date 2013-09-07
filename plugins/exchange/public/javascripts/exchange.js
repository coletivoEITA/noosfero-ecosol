
exchange = {

  updateField: function (self, url, options) {
    jQuery.post(url, options);
    //FIXME show loading

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

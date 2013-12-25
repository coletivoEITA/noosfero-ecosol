
oauth = {

  form: {

    submit: function (form, loadingSelector) {
      //jQuery(form).ajaxSubmit();
      jQuery.ajax({
        url: form.action, type: 'POST',
        contentType: false, processData: false, cache: false,
        data: new FormData(form),
        beforeSend: function() { loading_overlay.show(loadingSelector) },
        complete: function() { loading_overlay.hide(loadingSelector) },
      });
      return false;
    },
  },
}

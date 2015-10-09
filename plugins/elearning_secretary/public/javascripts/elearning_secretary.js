//= require views/elearning-secretary-context
//= require views/elearning-secretary-student

elearning_secretary = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'elearning_secretary_plugin'}))
  },


}

//@ sourceURL=plugins/elearning_secretary/javascripts/elearning_secretary.js

//= require views/elearning-secretary-context
//= require views/elearning-secretary-student
//= require views/elearning-secretary-documents-export

elearning_secretary = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'elearning_secretary_plugin'}))
  },

  routes: {
    manage: Routes.elearning_secretary_plugin_manage_path,
  }

}

//@ sourceURL=plugins/elearning_secretary/javascripts/elearning_secretary.js

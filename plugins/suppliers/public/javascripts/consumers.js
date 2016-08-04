//= require ./views/consumer-page
//= require ./views/consumer-box
//= require ./views/consumer-view

consumers = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'suppliers_plugin'}))
  },

}

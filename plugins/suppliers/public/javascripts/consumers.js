//= require ./views/consumer-page
//= require ./views/consumer-box

consumers = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'suppliers_plugin'}))
  },

}

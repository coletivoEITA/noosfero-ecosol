//= require ./views/product-page
//= require ./views/product-item

products = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'suppliers_plugin'}))
  },

}

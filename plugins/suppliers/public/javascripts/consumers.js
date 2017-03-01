//= require ./views/consumer-page
//= require ./views/consumer-box
//= require ./views/pending-consumer-box
//= require ./views/consumer-view
//= require ./views/consumer-add
//= require ./views/pending-consumer-view

consumers = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'suppliers_plugin'}))
  },

}
riot.tag('raw', '', function(opts) {
  this.root.innerHTML = opts.html;
});

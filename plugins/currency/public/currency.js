
currency = {
  list: null,

  find: function(id) {
    id = parseInt(id);
    return currency.list.find(function(c) { return c.id == id; });
  },
};

currency.search = {

  load: function() {
    this.input = jQuery();
    this.getResults = function(data) {};
    this.query = null;
    this.last_query = null;
    this.query_url = null;
    this.typing = false;
    this.pending = false;
  },

  do: function (input, url, getResults) {
    currency.search.input = input;
    currency.search.typing = true;
    currency.search.query = input.value;
    currency.search.query_url = url;
    currency.search.getResults = getResults;
    setTimeout(currency.search.timeout, 200);
  },

  timeout: function () {
    if (!currency.search.query ||
        (currency.search.last_query && currency.search.query == currency.search.last_query))
      return;
    currency.search.typing = false;
    currency.search.last_query = currency.search.query;

    currency.search.pending = true;
    currency.search.getResults();
  },
};

currency.disassociate = {

  search: function () {
    jQuery.get(currency.search.query_url, {query: currency.search.query}, function (data) {
      jQuery('#enterprise-results').html(data);
      currency.search.pending = false;
    });
  },
};

currency.accept = {

  load: function (hint) {
    input = jQuery('#search-query');
    input.hint(hint);
  },

  search: function () {
    jQuery.get(currency.search.query_url, {query: currency.search.query}, function (data) {
      jQuery('#currency-search').html(data);
      currency.search.pending = false;
    });
  },
};

currency.product = {

  priceRow: null,
  discountRow: null,

  setId: function (pc) {
    pc.id = pc.currency_id;
    return pc;
  },

  load: function(options) {
    currency.list = options.currencies;
    currency.product.priceRow = jQuery('#price-row');
    currency.product.discountRow = jQuery('#discount-row');

    currency.product.add('price', options.prices.map(currency.product.setId));
    currency.product.add('discount', options.discounts.map(currency.product.setId));

    jQuery('#price-currency-select').change(function () {
      var item = currency.find(jQuery(this).val());
      currency.product.add('price', [item]);
    });
    jQuery('#discount-currency-select').change(function () {
      var item = currency.find(jQuery(this).val());
      currency.product.add('discount', [item]);
    });
  },

  add: function(field, currencies) {
    currency.product[field+'Row'].after(currency.product.template(field, currencies));
  },

  template: function (field, currencies) {
    var template = jQuery('#currency-template');
    return _.template(template.html(), {field: field, currencies: currencies});
  },
};

// don't strip underscore templates within ruby templates
String.prototype.stripScripts = function () { return this; };

// sync get
jQuery.syncGet = function (url, data, success, dataType) {
  jQuery.ajax({async: false, method: 'GET', url: url,
    data: data, success: success, dataType: dataType});
};

window.addedScripts = window.addedScripts || [];
function addScript(src, onload) {
  if (window.addedScripts.indexOf(src) != -1)
    return;
  window.addedScripts.push(src);
  jQuery.syncGet(src, {}, function(js) { jQuery.globalEval(js); });
  if (onload != undefined)
    onload();
}

currency.underscore_settings = function () {
  // underscore use of <@ instead of <%
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/gim,
    evaluate: /\<\@(.+?)\@\>/gim
  };
};

// from http://stackoverflow.com/questions/17033397/javascript-strings-with-keyword-parameters
String.prototype.format = function(obj) {
  return this.replace(/%\{([^}]+)\}/g,function(_,k){ return obj[k] });
};


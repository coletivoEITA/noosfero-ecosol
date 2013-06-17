
currency = {};

currency.accept: {
  query: null,
  last_query: null,
  query_url: null,
  typing: false,
  pending: false,

  load: function (hint) {
    jQuery('#search-query').hint(hint);
  },

  search: function (input, url) {
    currency.accept.typing = true;
    setTimeout(currency.accept.search_timeout, 200);
    currency.accept.query = input.value;
    currency.accept.query_url = url;
  },

  search_timeout: function () {
    if (!currency.accept.query ||
        (currency.accept.last_query && currency.accept.query == currency.accept.last_query))
      return;
    currency.accept.typing = false;
    currency.accept.pending = true;
    currency.accept.last_query = currency.accept.query;
    jQuery.get(currency.accept.query_url, {query: currency.accept.query}, function (data) {
      currency.accept.pending = false;
      jQuery('#currency-search').html(data);
    });
  },
};

currency.product = {

  template: function (field, currency) {
    addScript('/plugins/currency/underscore-min.js');

    var container = jQuery('#currency-%{field}').format({field: field}));
    var template = container.find('.template');
    return _.template(template.html(), {: category});
    }).join('');
  },
};

window.addedScripts = window.addedScripts || [];
function addScript(src) {
  if (window.addedScripts.indexOf(src) != -1)
    return;
  window.addedScripts.push(src);
  jQuery("<script type='text/javascript' src='%{src}'".format({src: src})).appendTo(jQuery('head'));
}

// underscore use of <@ instead of <%
_.templateSettings = {
  interpolate: /\<\@\=(.+?)\@\>/gim,
  evaluate: /\<\@(.+?)\@\>/gim
};

// from http://stackoverflow.com/questions/17033397/javascript-strings-with-keyword-parameters
String.prototype.format = function(obj) {
  return this.replace(/%\{([^}]+)\}/g,function(_,k){ return obj[k] });
};


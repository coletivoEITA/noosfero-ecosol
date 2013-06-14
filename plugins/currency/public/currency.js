
currency = {

  accept: {
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

  },
};

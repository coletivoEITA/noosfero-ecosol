

escambo = {

};

escambo.home = {

  scrollLeft: function() {

  },
  scrollRight: function() {

  },
};

escambo.search = {

  load: function() {
    this.input = jQuery();
    this.getResults = function(data) {};
    this.query = null;
    this.last_query = null;
    this.query_url = null;
    this.typing = false;
    this.pending = false;
    this.timeout = 200;
  },

  do: function (input, url, getResults) {
    this.input = input;
    this.typing = true;
    this.query = input.value;
    this.query_url = url;
    this.getResults = getResults;
    setTimeout(this.expire, this.timeout);
  },

  expire: function () {
    if (!this.query || (this.last_query && this.query == this.last_query))
      return;
    this.typing = false;
    this.last_query = this.query;

    this.pending = true;
    this.getResults();
  },
};
escambo.search.load();

escambo.signup = {

  enterprise: {

    find: function() {
      jQuery('#enterprise-register').toggle();
      jQuery('#enterprise-find').toggle();
    },
    register: function() {
      this.find();
    },

    search: function () {
      jQuery.get(escambo.search.query_url, {query: escambo.search.query}, function (data) {
        jQuery('#enterprise-results').html(data);
        escambo.search.pending = false;
      });
    },
  },
}

jQuery('.scroll-left').click(escambo.home.scrollLeft);

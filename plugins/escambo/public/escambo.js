

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
    this.input = jQuery(input);
    this.typing = true;
    this.query = input.value;
    this.query_url = url;
    this.getResults = getResults;
    setTimeout(this.expire, this.timeout);
  },

  start: function () {
    if (!this.query || (this.last_query && this.query == this.last_query))
      return;
    this.pending = false;
    this.typing = false;
    this.last_query = this.query;
    this.pending = true;
    this.input.addClass('loading');
    this.getResults();
  },
  finish: function () {
    this.pending = false;
    this.input.removeClass('loading');
  },

  expire: function () {
    escambo.search.start();
  },
};
escambo.search.load();

escambo.signup = {

  load: function (empty_selection_message) {
    jQuery('#signup-form').submit(function (e) {
      e.preventDefault();
      if (escambo.signup.enterprise.hasSelection())
        this.submit();
      else
        alert(empty_selection_message);
    });
  },

  enterprise: {

    find: function() {
      jQuery('#enterprise-register, #enterprise-find').toggle();
      jQuery('#enterprise-register-field').val(jQuery('#enterprise-register').is(':visible'));
    },
    register: function() {
      this.find();
    },

    hasSelection: function () {
      find = jQuery('#enterprise-find');
      return (find.is(':visible') &&
          find.find("input[name='enterprise_id']").is(':checked'));
    },

    search: function () {
      jQuery.get(escambo.search.query_url, {query: escambo.search.query}, function (data) {
        jQuery('#enterprise-results').html(data);
        escambo.search.finish();
      });
    },
  },
}

jQuery('.scroll-left').click(escambo.home.scrollLeft);

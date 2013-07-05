
escambo = {

};

escambo.scroll = function (crop, attr, multiplier, unitSize) {
  if (crop.is(':animated'))
    return;
  params = {}; params[attr] = parseInt(crop.css(attr)) + Math.floor(multiplier)*unitSize;
  crop.animate(params);
};

escambo.home = {
};

escambo.home.enterprises = {

  area: function () {
    return jQuery('#enterprises-area');
  },
  crop: function () {
    return jQuery('#enterprises-crop');
  },
  children: function () {
    return jQuery('.escambo-plugin-profile-block');
  },
  childrenFit: function () {
    return Math.floor(this.area().width() / this.childSize());
  },
  childSize: function () {
    return this.children().outerWidth(true);
  },

  scroll: function (multiplier) {
    escambo.scroll(this.crop(), 'margin-left', multiplier, this.childSize());
  },
  scrollLeft: function () {
    self = escambo.home.enterprises;
    if (self.area().isChildOverflowing(self.children().first()))
      escambo.home.enterprises.scroll(1);
  },
  scrollRight: function () {
    self = escambo.home.enterprises;
    if (self.area().isChildOverflowing(self.children().last()))
      escambo.home.enterprises.scroll(-1);
  },
  scrollMiddle: function () {
    escambo.home.enterprises.scroll(-(this.children().length - this.childrenFit()) / 2);
  },
};

escambo.currency = {

  popin: function (nameElement) {
    var item = jQuery(nameElement).parents('.currency-item');
    var parent = item.find('.popin');
    currency.popin.show(parent);
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
    var form = jQuery('#signup-form');
    form.submit(function (e) {
      e.preventDefault();
      if (form.find('input[name=enterprise_register]').val() == 'true' || escambo.signup.enterprise.hasSelection())
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

jQuery(document).ready(function () {
  jQuery('.scroll-left').click(escambo.home.enterprises.scrollLeft);
  jQuery('.scroll-right').click(escambo.home.enterprises.scrollRight);
  escambo.home.enterprises.scrollMiddle();
});

jQuery.fn.isChildOverflowing = function (child) {
  var p = jQuery(this).get(0);
  var el = jQuery(child).get(0);
  return (el.offsetTop < p.offsetTop || el.offsetLeft < p.offsetLeft) ||
    (el.offsetTop + el.offsetHeight > p.offsetTop + p.offsetHeight || el.offsetLeft + el.offsetWidth > p.offsetLeft + p.offsetWidth);
};


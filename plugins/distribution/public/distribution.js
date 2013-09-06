distribution = {

  edit_arrow_toggle: function (context, toggle) {
    arrow = jQuery(context).hasClass('actions-circle') ? jQuery(context) : jQuery(context).find('.actions-circle');

    arrow.toggleClass('edit', toggle);
    return arrow.hasClass('edit');
  },

  toggle_header_color_area: function(t) {
    if (t.value != 'pure_color') {
      jQuery('#distribution-header-bg-color input').each(function(f){
        $(this).disable();
      });
      jQuery('#distribution-header-bg-color div.color-choose').each(function(f){
        $(this).addClassName('disabled');
      });
    }
    else {
      jQuery('#distribution-header-bg-color input').each(function(f) {
        $(this).enable();
      });
      jQuery('#distribution-header-bg-color div.color-choose').each(function(f){
        $(this).removeClassName('disabled');
      });
    }
  },

  calculate_price: function (price_input, margin_input, base_price_input) {
    var price = unlocalize_currency(jQuery(price_input).val());
    var base_price = unlocalize_currency(jQuery(base_price_input).val());
    var margin = unlocalize_currency(jQuery(margin_input).val());

    var value = base_price + (margin / 100) * base_price;
    if (isNaN(value))
      value = unlocalize_currency(base_price_input.val());
    jQuery(price_input).val(localize_currency(value));
  },
  calculate_margin: function (margin_input, price_input, base_price_input) {
    var price = unlocalize_currency(jQuery(price_input).val());
    var base_price = unlocalize_currency(jQuery(base_price_input).val());
    var margin = unlocalize_currency(jQuery(margin_input).val());

    var value = ((price - base_price) / base_price ) * 100;
    value = !isFinite(value) ? '' : localize_currency(value);
    jQuery(margin_input).val(value);
  },

  /* ----- session stuff  ----- */

  in_session_order_toggle: function (context) {
    container = jQuery(context).hasClass('session-orders') ? jQuery(context) : jQuery(context).parents('.session-orders');
    container.toggleClass('show');
    container.find('.order-content').toggle();
    distribution.edit_arrow_toggle(container);
  },

  /* ----- ends session stuff  ----- */


  /* ----- order stuff  ----- */

  order_product_include: function (message, url) {
    if (message)
      alert(message);
    return false;
  },

  order_products_toggle: function (fields, toggle) {
    jQuery.each(fields, function(index, field) {
      var p = jQuery(field).parents('.order-session-product');
      p.toggle(toggle);
      //v = p.is(':visible');
      //toggle ? (!v ? p.fadeIn() : 0) : (v ? p.fadeOut() : 0);
    });
  },

  /* ----- ends order stuff  ----- */

  /* ----- session editions stuff  ----- */

  offered_product: {

    pmsync: function (context, to_price) {
      p = jQuery(context).parents('.session-product .box-edit');
      margin = p.find('#product_margin_percentage');
      price = p.find('#product_price');
      buy_price = p.find('#product_buy_price');
      original_price = p.find('#product_original_price');
      base_price = unlocalize_currency(buy_price.val()) ? buy_price : original_price;

      if (to_price)
        distribution.calculate_price(price, margin, base_price);
      else
        distribution.calculate_margin(margin, price, base_price);
    },

  },

  /* ----- ends session editions stuff  ----- */

  table: {

    header_click: function () {
      this.ascending = !this.ascending;
      header = jQuery(this).parents('.table-header');
      content = header.siblings('.table-content');
      jQuerySort(content.children('.value-row'), {find: '.'+this.classList[1], ascending: this.ascending});

      arrow = header.find('.sort-arrow').length > 0 ? header.find('.sort-arrow') : jQuery('<div class="sort-arrow"/>').appendTo(header);
      arrow.toggleClass('desc', !this.ascending).css({
        top: jQuery(this).position().top + jQuery(this).height() - 1,
        left: jQuery(this).position().left + parseInt(jQuery(this).css('margin-left')) + parseInt(jQuery(this).css('padding-left'))
      });
    },

  },

  /* ----- toggle edit stuff  ----- */

  offered_product_edit: function () {
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
  },
  session_mail_message_toggle: function () {
    if ($('session-new-mail-send').checked) {
      jQuery('#session-new-mail').removeClass('disabled');
      jQuery('#session-new-mail textarea').removeAttr('disabled');
    } else {
      jQuery('#session-new-mail').addClass('disabled');
      jQuery('#session-new-mail textarea').attr('disabled', true);
    }
  },
  order_offered_product_toggle: function () {
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    toggle_edit.editing().find('.quantity-label').toggle(!toggle_edit.isEditing());
    toggle_edit.editing().find('.quantity-entry').toggle(toggle_edit.isEditing());
  },

  checkbox_change: function () {
    jQuery(this).attr('checked', this.checked ? 'checked' : null);
    return false;
  },

  colorbox: function (options) {
    options.innerWidth = 500;
    jQuery.colorbox(options);
  },

  // block user actions while making a post. Also indicate the network transaction
  setLoading: function (element) {
    var pos       = jQuery.extend({
      width:    jQuery("#"+element).outerWidth(),
    height:   jQuery("#"+element).outerHeight()
    }, jQuery("#"+element).position());
    jQuery('<div>', {
      id: element + '-overlay',
      css:   {
        position:         'absolute',
      top:              pos.top,
      left:             pos.left,
      width:            pos.width,
      height:           pos.height,
      backgroundImage:  'url(/plugins/distribution/images/loading.gif)',
      opacity:          0.90,
      zIndex:          10
      }
    }).appendTo(jQuery("#"+element));
  },

  unsetLoading: function (element) {
    jQuery("#"+element+"-overlay").remove();
  },

  ajaxifyPagination: function(elementId) {
    jQuery(".pagination a").click(function() {
      distribution.setLoading(elementId);
      jQuery.ajax({
        type: "GET",
        url: jQuery(this).attr("href"),
        dataType: "script"
      });
      return false;
    });
  },

  toggleCancelledOrders: function () {
    jQuery('.plugin-distribution #show-cancelled-orders a').toggle();
    jQuery('.plugin-distribution #hide-cancelled-orders a').toggle();
    jQuery('.plugin-distribution .consumer-order:not(.edit) .status-cancelled').toggle();
  },
}

/* ----- events  ----- */

jQuery('.plugin-distribution input[type=checkbox]').live('change', distribution.checkbox_change);
jQuery('.plugin-distribution .table-header .box-field').live('click', distribution.table.header_click);

/* ----- ends events  ----- */

/* ----- infrastructure stuff  ----- */

(function($) {
  $.fn.toggleDisabled = function() {
    return this.each(function() {
      this.disabled = !this.disabled;
    });
  };
})(jQuery);

Array.prototype.diff = function(a) {
  return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};
Array.prototype.sum = function(){
  for(var i=0,sum=0;i<this.length;sum+=this[i++]);
    return sum;
}
Array.prototype.max = function(){
  return Math.max.apply({}, this);
}
Array.prototype.min = function(){
  return Math.min.apply({}, this);
}

function jQuerySort(elements, options) {
  if (typeof options === 'undefined') options = {};
  options.ascending = typeof options.ascending === 'undefined' ? 1 : (options.ascending ? 1 : -1);
  var list = elements.get();
  list.sort(function(a, b) {
    var compA = (options.find ? jQuery(a).find(options.find) : jQuery(a)).text().toUpperCase();
    var compB = (options.find ? jQuery(b).find(options.find) : jQuery(b)).text().toUpperCase();
    return options.ascending * ((compA < compB) ? -1 : (compA > compB) ? 1 : 0);
  });
  parent = elements.first().parent();
  jQuery.each(list, function(index, element) { parent.append(element); });
}

/* ----- ends infrastructure stuff  ----- */

/* ----- localization stuff  ----- */

locale = 'pt'; //FIXME: don't hardcode
standard_locale = 'en';
code_locale = 'code';
locale_info = {
  'code': {
    'currency': {
      'delimiter': '',
      'separator': '.',
      'decimals': null,
    }
  },
  'en': {
    'currency': {
      'delimiter': ',',
      'separator': '.',
      'decimals': 2,
    }
  },
  'pt': {
    'currency': {
      'delimiter': '.',
      'separator': ',',
      'decimals': 2,
    }
  },
}

function localize_currency(value, to, from) {
  if (!to)
    to = locale;
  if (!from)
    from = standard_locale;
  var lvalue = unlocalize_currency(value, from);
  from = standard_locale;
  lvalue = lvalue.toFixed(locale_info[to].currency.decimals);
  lvalue = lvalue.replace(locale_info[from].currency.delimiter, locale_info[to].currency.delimiter);
  lvalue = lvalue.replace(locale_info[from].currency.separator, locale_info[to].currency.separator);
  return lvalue;
}

function unlocalize_currency(value, from) {
  if (!value)
    return 0;
  if (!from)
    from = locale;
  var lvalue = value.toString();
  var to = code_locale;
  lvalue = lvalue.replace(locale_info[from].currency.delimiter, locale_info[to].currency.delimiter);
  lvalue = lvalue.replace(locale_info[from].currency.separator, locale_info[to].currency.separator);
  return parseFloat(lvalue);
}

/* ----- ends localization stuff  ----- */


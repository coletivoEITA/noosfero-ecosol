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

  /* ----- delivery stuff  ----- */

  delivery_view_toggle: function () {
    jQuery('#delivery-method-choose, #delivery-method-edit').toggle();
  },

  /* ----- ends delivery stuff  ----- */

  /* ----- category select stuff  ----- */

  category: null,

  category_toggle_view: function (edit, view) {
    edit.find('.category-selected').toggle(view == 1);
    edit.find('.category-hierarchy').toggle(view != 0);
    edit.find('.category-type-select').toggle(view == 2);
    edit.find('.field-box').toggle(view == 0);
    distribution.our_product.css_align();
  },

  subcategory_select: function (context) {
    edit = jQuery(context).parents('.category-edit');
    option = context.options[context.selectedIndex];
    edit.find('.category-hierarchy .type').text(jQuery(option).text());

    distribution.category_toggle_view(edit, 1);
  },

  category_reselect_sub: function () {
    edit.find('.category-hierarchy .type').text('');
    distribution.category_toggle_view(edit, 2);
  },

  category_select_another: function (context) {
    edit = jQuery(context).parents('.category-edit');
    edit.find('#product_category_id').tokenInput('clear');

    distribution.category_toggle_view(edit, 0);
  },

  category_reselect: function (context, item) {
    jQuery(context).parents('.category').nextAll('.category').remove();
    jQuery(context).parents('.category').siblings('.type').text('');
    edit = jQuery(context).parents('.category-edit');
    edit.find('#product_category_id').val(item.id);
    category = item;
    distribution.category_template_type_select(edit);
    distribution.category_toggle_view(edit, 2);
  },

  category_template_hierarchy: function (edit) {
    edit.find('.category-hierarchy div').html(_.template(edit.find('.category-hierarchy script').html(), {cat: category}));
  },
  category_template_type_select: function (edit, selected) {
    edit.find('.category-type-select div').html(_.template(edit.find('.category-type-select script').html(), {cat: category, selected: selected}));
    if (selected)
      edit.find('select').get(0).onchange();
  },
  category_select: function (item) {
    category = item;
    edit = jQuery(this).parents('.category-edit');
    distribution.category_template_hierarchy(edit);
    distribution.category_template_type_select(edit);

    distribution.category_toggle_view(edit, 2);
  },

  /* ----- end category select stuff  ----- */

  /* ----- our products stuff  ----- */

  our_product: {

    toggle_edit: function () {
      if (toggle_edit.editing().is('#our-product-add'))
        toggle_edit.editing().toggle(toggle_edit.isEditing());
      toggle_edit.editing().find('.box-view').toggle(!toggle_edit.isEditing());
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());

      distribution.our_product.css_align();
    },

    add_link: function () {
      if (toggle_edit.isEditing())
        toggle_edit.value_row.toggle_edit();
      toggle_edit.setEditing(jQuery('#our-product-add'));
      toggle_edit.value_row.toggle_edit();
    },

    load: function(el) {
      // load default logic
      el.find('#product_default_margin_percentage').get(0).onchange();
      // click
      el.find('.properties-block').click(distribution.our_product.enable_if_disabled);
    },

    enable_if_disabled: function (event) {
      target = jQuery(event.target);
      if (target.is('input[type=text][disabled], select[disabled]')) {
        product = jQuery(target).parents('.our-product');
        default_checkbox = jQuery(jQuery.grep(product.find('input[type=checkbox][for]'), function(element, index) {
          return jQuery(element).attr('for').indexOf(target.attr('id')) >= 0;
        }));
        default_checkbox.attr('checked', null);
        distribution.our_product.toggle_referred(default_checkbox);
        target.focus();
      }
    },

    toggle_referred: function (context) {
      var is_margin = jQuery(context).attr('id') == 'product_default_margin_percentage';
      var p = jQuery(context).parents('.box-edit');
      var referred = p.find(jQuery(context).attr('for'));

      jQuery.each(referred, function(i, field) {
        // disable or enable according to checkbox
        field.disabled = context.checked;

        if (field.disabled) {
          // keep current value in oldvalue
          jQuery(field).attr('oldvalue', jQuery(field).val());
          // put default value or supplier value in it
          jQuery(field).val(field.hasAttribute('defaultvalue')
            ? jQuery(field).attr('defaultvalue')
            : p.find('#'+field.id.replace('product', 'product_supplier_product')).val()
          );
        } else {
          // put back custom value
          jQuery(field).val(jQuery(field).attr('oldvalue'));
        }

        // blank margin oldvalue if it is equal to default
        // this is necessary because if oldvalue is equal to default value the
        // checkbox will tick again
        if (is_margin && field.disabled)
          jQuery(field).attr('oldvalue', '');

        if (field.onkeyup)
          field.onkeyup();
      });
      referred.first().focus();
    },
    sync_referred: function (context) {
      var p = jQuery(context).parents('.box-edit');
      var referred = p.find('#'+context.id.replace('product_supplier_product', 'product')).get(0);
      if (!referred)
        return;
      if (referred.disabled)
        jQuery(referred).val(jQuery(context).val());
      if (referred.onkeyup)
        referred.onkeyup();
    },
    pmsync: function (context, to_price) {
      var p = jQuery(context).parents('.our-product');
      var margin_input = p.find('#product_margin_percentage');
      var price_input = p.find('#product_price');
      var buy_price_input = p.find('#product_supplier_product_price');

      if (to_price)
        distribution.calculate_price(price_input, margin_input, buy_price_input);
      else
        distribution.calculate_margin(margin_input, price_input, buy_price_input);

      // auto check 'use default margin'
      if (!to_price) {
        var default_margin_input = p.find('#product_default_margin_percentage');
        var newvalue = unlocalize_currency(margin_input.val());
        var defaultvalue = unlocalize_currency(margin_input.attr('defaultvalue'));
        var oldvalue = unlocalize_currency(margin_input.attr('oldvalue'));
        var currentchecked = default_margin_input.get(0).checked;
        var checked = newvalue == defaultvalue;
        default_margin_input.attr('checked', checked ? 'checked' : null);
        margin_input.get(0).disabled = checked;
      }
    },

    add_missing_products: function (context, url) {
      distribution.setLoading('our-product-add');
      supplier = jQuery('#our-product-add').find('#product_supplier_id');
      jQuery.post(url, jQuery(supplier).serialize(), function() {
      });
      distribution.unsetLoading('our-product-add');
    },
    add_change_supplier: function (context, url) {
      distribution.setLoading('our-product-add');
      jQuery('#our-product-add').load(url, jQuery(context).serialize(), function() {
        distribution.our_product.toggle_edit();
      });
    },
    add_from_product: function (context, url, data) {
      distribution.setLoading('our-product-add');
      jQuery('#our-product-add').load(url, data, function() {
        distribution.our_product.toggle_edit();
      });
      distribution.unsetLoading('our-product-add');
    },

    css_align: function () {
      var distributed = toggle_edit.editing().find('.our-product-distributed-column');
      var use_original = toggle_edit.editing().find('.our-product-use-original-column');
      var supplied = toggle_edit.editing().find('.our-product-supplied-column');

      use_original.height(distributed.height());
      supplied.height(distributed.height());

      if (supplied.length > 0)
        supplied.find('.price-block').css('top', distributed.find('.price-block').position().top);

      use_original.find('input[type=checkbox]').each(function(index, checkbox) {
        checkbox = jQuery(checkbox);
        checkbox.css('top', distributed.find(checkbox.attr('for')).first().position().top - use_original.find('.guideline').position().top);
      });
    },

  },

  /* ----- ends our products stuff  ----- */

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

  in_session_order_toggle_edit: function () {
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    distribution.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
  },

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
  ordered_product_edit: function () {
    toggle_edit.editing().find('.more-actions').toggle(toggle_edit.isEditing());
    if (toggle_edit.isEditing())
      toggle_edit.editing().find('.product-quantity input').focus();
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

  toggleCancelledOrders: function (el) {
    jQuery('.plugin-distribution #show-cancelled-orders a').toggle();
    jQuery('.plugin-distribution #hide-cancelled-orders a').toggle();
    jQuery('.plugin-distribution .consumer-order:not(.edit) .status-cancelled').toggle()
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

_.templateSettings = {
  evaluate: /\{\{([\s\S]+?)\}\}/g,
  interpolate: /\{\{=([\s\S]+?)\}\}/g,
  escape: /\{\{-([\s\S]+?)\}\}/g
}

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


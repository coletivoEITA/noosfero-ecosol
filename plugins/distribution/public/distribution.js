distribution = {

  _editing: jQuery(),
  _isInner: false,

  setEditing: function (value) {
    distribution._editing = jQuery(value);
  },
  editing: function () {
    return distribution._editing.first();
  },
  isEditing: function () {
    return distribution.editing().first().hasClass('edit');
  },

  edit_arrow_toggle: function (context, toggle) {
    arrow = jQuery(context).hasClass('actions-circle') ? jQuery(context) : jQuery(context).find('.actions-circle');

    arrow.toggleClass('edit', toggle);
    return arrow.hasClass('edit');
  },


  calculate_price: function (price_input, margin_input, base_price_input) {
    var price = parseFloat(jQuery(price_input).val().replace(',','.'));
    var base_price = parseFloat(jQuery(base_price_input).val().replace(',','.'));
    var margin = parseFloat(jQuery(margin_input).val().replace(',','.'));

    var value = distribution.currency( base_price + (margin / 100) * base_price );
    jQuery(price_input).val( isNaN(value) ? base_price_input.val().replace(',','.') : value );
  },
  calculate_margin: function (margin_input, price_input, base_price_input) {
    var price = parseFloat(jQuery(price_input).val().replace(',','.'));
    var base_price = parseFloat(jQuery(base_price_input).val().replace(',','.'));
    var margin = parseFloat(jQuery(margin_input).val().replace(',','.'));

    var value = distribution.currency( ((price - base_price) / base_price ) * 100 );
    jQuery(margin_input).val( isFinite(value) ? value : '' );
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
    distribution.our_product_css_align();
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

  our_product_enable_if_disabled: function (event) {
    target = jQuery(event.target);
    if (target.is('input[type=text][disabled], select[disabled]')) {
      product = jQuery(target).parents('.our-product');
      default_checkbox = jQuery(jQuery.grep(product.find('input[type=checkbox][for]'), function(element, index) {
          return jQuery(element).attr('for').indexOf(target.attr('id')) >= 0;
      }));
      default_checkbox.attr('checked', null);
      distribution.our_product_toggle_referred(default_checkbox);
      target.focus();
    }
  },

  our_product_toggle_referred: function (context) {
    var p = jQuery(context).parents('.box-edit');
    var referred = p.find(jQuery(context).attr('for'));

    jQuery.each(referred, function(i, value) {
      value.disabled = context.checked;

      if (value.disabled) {
        jQuery(value).attr('oldvalue', jQuery(value).val());
        jQuery(value).val(value.hasAttribute('defaultvalue')
          ? jQuery(value).attr('defaultvalue') : p.find('#'+value.id.replace('product', 'product_supplier_product')).val());
      } else {
        jQuery(value).val(jQuery(value).attr('oldvalue'));
      }

      if (value.onkeyup)
        value.onkeyup();
    });
    referred.first().focus();
  },
  our_product_sync_referred: function (context) {
    var p = jQuery(context).parents('.box-edit');
    var referred = p.find('#'+context.id.replace('product_supplier_product', 'product')).get(0);
    if (referred && referred.disabled) {
      jQuery(referred).val(jQuery(context).val());

      if (referred.onkeyup)
        referred.onkeyup();
    }
  },
  our_product_add_missing_products: function (context, url) {
    distribution.setLoading('our-product-add');
    supplier = jQuery('#our-product-add').find('#product_supplier_id');
    jQuery.post(url, jQuery(supplier).serialize(), function() {
    });
    distribution.unsetLoading('our-product-add');
  },
  our_product_add_change_supplier: function (context, url) {
    distribution.setLoading('our-product-add');
    jQuery('#our-product-add').load(url, jQuery(context).serialize(), function() {
      distribution.our_product_toggle_edit();
    });
  },
  our_product_add_from_product: function (context, url, data) {
    distribution.setLoading('our-product-add');
    jQuery('#our-product-add').load(url, data, function() {
      distribution.our_product_toggle_edit();
    });
    distribution.unsetLoading('our-product-add');
  },

  our_product_pmsync: function (context, to_price) {
    var p = jQuery(context).parents('.our-product');
    var margin_input = p.find('#product_margin_percentage');
    var price_input = p.find('#product_price');
    var buy_price_input = p.find('#product_supplier_product_price');
    var default_margin_input = p.find('#product_default_margin_percentage');

    if (!margin_input.get(0)) //own product don't have a margin
      return;

    if (to_price || price_input.get(0).disabled)
      distribution.calculate_price(price_input, margin_input, buy_price_input);
    else {
      var oldvalue = parseFloat(margin_input.val().replace(',','.'));
      distribution.calculate_margin(margin_input, price_input, buy_price_input);
      var newvalue = parseFloat(margin_input.val().replace(',','.'));
      if (newvalue != oldvalue) {
        var checked = newvalue == parseFloat(margin_input.attr('defaultvalue').toString().replace(',','.'));
        default_margin_input.attr('checked', checked ? 'checked' : null);
        margin_input.get(0).disabled = checked;
      }
    }
  },

  our_product_css_align: function () {
    var distributed = distribution.editing().find('.our-product-distributed-column');
    var use_original = distribution.editing().find('.our-product-use-original-column');
    var supplied = distribution.editing().find('.our-product-supplied-column');

    use_original.height(distributed.height());
    supplied.height(distributed.height());

    if (supplied.length > 0)
      supplied.find('.price-block').css('top', distributed.find('.price-block').position().top);

    use_original.find('input[type=checkbox]').each(function(index, checkbox) {
      checkbox = jQuery(checkbox);
      checkbox.css('top', distributed.find(checkbox.attr('for')).first().position().top - use_original.find('.guideline').position().top);
    });
  },

  /* ----- ends our products stuff  ----- */

  /* ----- order stuff  ----- */

  order_products_toggle: function (fields, toggle) {
    jQuery.each(fields, function(index, field) {
      var p = jQuery(field).parents('.order-session-product');
      p.toggle(toggle);
      //v = p.is(':visible');
      //toggle ? (!v ? p.fadeIn() : 0) : (v ? p.fadeOut() : 0);
    });
  },

  order_filter_products: function (text) {
    text = text.toLowerCase();
    fields = jQuery('#session-products-for-order .box-field');
    results = jQuery.grep(fields, function(field, index) {
      fieldText = jQuery(field).text().toLowerCase();
      supplierText = jQuery(field).parents('.supplier-table').find('.supplier').text().toLowerCase();

      matchField = fieldText.indexOf(text) > -1;
      matchSupplier = supplierText.indexOf(text) > -1;
      return matchField || matchSupplier;
    });
    jQuery('#session-products-for-order .supplier-table').show();
    distribution.order_products_toggle(jQuery(fields), false);
    distribution.order_products_toggle(jQuery(results), true);

    jQuery('#session-products-for-order .supplier-table').each(function(index, supplier) {
      jQuery(supplier).toggle(jQuery(supplier).find('.order-session-product:visible').length > 0 ? true : false);
    });
  },

  order_filter: function () {
    distribution.order_filter_products(jQuery(this).text());
    jQuery(this).parents('#order-filter').find('input').val(jQuery(this).text());
  },

  /* ----- ends order stuff  ----- */

  /* ----- session editions stuff  ----- */

  session_product_pmsync: function (context, to_price) {
    p = jQuery(context).parents('.session-product-edit');
    margin = p.find('#product_margin_percentage');
    price = p.find('#product_price');
    buy_price = p.find('#product_buy_price');
    if (to_price)
      distribution.calculate_price(price, margin, buy_price);
    else
      distribution.calculate_margin(margin, price, buy_price);
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

  supplier_add_link: function () {
    if (distribution.isEditing())
      distribution.value_row.toggle_edit();
    distribution.setEditing(jQuery('#supplier-add'));
    distribution.value_row.toggle_edit();
  },
  supplier_toggle_edit: function () {
    if (distribution.editing().is('#supplier-add'))
      distribution.editing().toggle(distribution.isEditing());
    distribution.editing().find('.box-view').toggle(!distribution.isEditing());
    distribution.editing().find('.box-edit').toggle(distribution.isEditing());
  },
  in_session_order_toggle_edit: function () {
    distribution.editing().find('.box-edit').toggle(distribution.isEditing());
    distribution.edit_arrow_toggle(distribution.editing(), distribution.isEditing());
  },
  our_product_add_link: function () {
    if (distribution.isEditing())
      distribution.value_row.toggle_edit();
    distribution.setEditing(jQuery('#our-product-add'));
    distribution.value_row.toggle_edit();
  },
  our_product_toggle_edit: function () {
    if (distribution.editing().is('#our-product-add'))
      distribution.editing().toggle(distribution.isEditing());
    distribution.editing().find('.box-view').toggle(!distribution.isEditing());
    distribution.editing().find('.box-edit').toggle(distribution.isEditing());

    distribution.our_product_css_align();
  },
  session_product_edit: function () {
    distribution.editing().find('.box-edit').toggle(distribution.isEditing());
  },
  order_session_product_toggle: function () {
    distribution.editing().find('.box-edit').toggle(distribution.isEditing());
    distribution.editing().find('.quantity-label').toggle(!distribution.isEditing());
    distribution.editing().find('.quantity-entry').toggle(distribution.isEditing());
  },
  ordered_product_edit: function () {
    distribution.editing().find('.more-actions').toggle(distribution.isEditing());
    if (distribution.isEditing())
      distribution.editing().find('.product-quantity input').focus();
  },

  locate_value_row: function (context) {
    return jQuery(context).hasClass('value-row') ? jQuery(context) : jQuery(context).parents('.value-row');
  },

  target_isToggle: function (target) {
    return (jQuery(target).hasClass('box-edit-link') && !distribution.isEditing()) ||
      jQuery(target).hasClass('toggle-edit') || jQuery(target).parents().hasClass('toggle-edit');
  },

  document_click: function(event) {
    var isToggle = distribution.target_isToggle(event.target);
    var out = distribution.locate_value_row(event.target).length == 0;
    if (!isToggle && out && distribution.isEditing()) {
      distribution.value_row.toggle_edit();
      return false;
    }
    return true;
  },

  open_anchor: function () {
    el = jQuery(window.location.hash);
    distribution.value_row.reload();
    if (el.hasClass('value-row')) {
      distribution.setEditing(el);
      distribution.value_row.toggle_edit();
    }
  },

  currency: function (value) {
    return parseFloat(value.toString().replace(',','.')).toFixed(2);
  },

  value_row: {
    mouseenter: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).addClass('hover');
    },

    mouseleave: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).removeClass('hover');
    },

    click: function (event) {
      var value_row = distribution.locate_value_row(event.target);
      var now_isInner = value_row.length > 1;

      if (jQuery(event.target).hasClass('toggle-ignore-event'))
        return true;

      var isToggle = distribution.target_isToggle(event.target);
      var isAnother = value_row.get(0) != distribution.editing().get(0) || (now_isInner && !distribution._isInner);
      if (now_isInner && !distribution._isInner)
        distribution.setEditing(value_row);
      distribution._isInner = now_isInner;

      if (!isToggle && value_row.attr('without-click-edit') != undefined)
        return;

      if (isToggle) {
        if (isAnother)
          distribution.value_row.toggle_edit();
        distribution.setEditing(value_row);
        distribution.value_row.toggle_edit();

        return false;
      } else if (isAnother || !distribution.isEditing()) {
        if (distribution.isEditing())
          distribution.value_row.toggle_edit();
        distribution.setEditing(value_row);
        if (!distribution.isEditing())
          distribution.value_row.toggle_edit();

        return false;
      }

      return true;
    },

    toggle_edit: function () {
      distribution.editing().toggleClass('edit');
      eval(distribution.editing().attr('toggleedit'));
      if (!distribution.isEditing()) {
        if (distribution._editing.length > 1)
          distribution.setEditing(jQuery(distribution._editing[1]));
        else
          distribution.setEditing(jQuery());
      }
    },
    reload: function () {
      distribution.value_row.toggle_edit();
    },

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
}

/* ----- events  ----- */

jQuery('.plugin-distribution .value-row').live('mouseenter', distribution.value_row.mouseenter);
jQuery('.plugin-distribution .value-row').live('mouseleave', distribution.value_row.mouseleave);
jQuery('.plugin-distribution .value-row').live('click', distribution.value_row.click);
jQuery('.plugin-distribution input[type=checkbox]').live('change', distribution.checkbox_change);
jQuery('.plugin-distribution .table-header .box-field').live('click', distribution.table.header_click);

jQuery(document).click(distribution.document_click);
jQuery(document).ready(distribution.open_anchor);
jQuery(window).bind('hashchange', distribution.open_anchor);

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


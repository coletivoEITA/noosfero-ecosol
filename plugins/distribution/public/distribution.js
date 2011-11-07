var _editing = jQuery();
var _inner_editing = jQuery();
var _isInner = false;

function setEditing(value) {
  window['_editing'] = value;
}
function editing() {
  return jQuery(_editing[0]);
}
function isEditing() {
  return editing().hasClass('edit');
}

function distribution_edit_arrow_toggle(arrow, toggle) {
  arrow = jQuery(arrow);
  if (!arrow.hasClass('actions-circle'))
    arrow = arrow.find('.actions-circle');

  arrow.toggleClass('edit', toggle);
  return arrow.hasClass('edit');
}


function distribution_calculate_price(price_input, margin_input, base_price_input) {
  price = parseFloat(jQuery(price_input).val());
  base_price = parseFloat(jQuery(base_price_input).val());
  margin = parseFloat(jQuery(margin_input).val());

  value = distribution_currency( base_price + (margin / 100) * base_price );
  jQuery(price_input).val( isNaN(value) ? base_price_input.val() : value );
}
function distribution_calculate_margin(margin_input, price_input, base_price_input) {
  price = parseFloat(jQuery(price_input).val());
  base_price = parseFloat(jQuery(base_price_input).val());
  margin = parseFloat(jQuery(margin_input).val());

  value = distribution_currency( ((price - base_price) / base_price ) * 100 );
  jQuery(margin_input).val( isFinite(value) ? value : '' );
}

/* ----- our products stuff  ----- */

function distribution_our_product_toggle_referred(context) {
  p = jQuery(context).parents('.box-edit');
  referred = p.find(jQuery(context).attr('for'));

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
}
function distribution_our_product_sync_referred(context) {
  p = jQuery(context).parents('.box-edit');
  referred = p.find('#'+context.id.replace('product_supplier_product', 'product')).get(0);
  if (referred && referred.disabled)
    jQuery(referred).val(jQuery(context).val());
}
function distribution_our_product_add_change_supplier(context, url) {
  jQuery('#our-product-add').load(url, jQuery(context).serialize(), function() {
    distribution_our_product_add();
  });
}
function distribution_our_product_add_from_product(context, url, data) {
  jQuery('#our-product-add').load(url, data, function() {
    distribution_our_product_add();
  });
}

function distribution_our_product_pmsync(context, to_price) {
  var p = jQuery(context).parents('.our-product');
  var margin_input = p.find('#product_margin_percentage');
  var price_input = p.find('#product_price');
  var buy_price_input = p.find('#product_supplier_product_price');
  if (to_price || price_input.get(0).disabled)
    distribution_calculate_price(price_input, margin_input, buy_price_input);
  else {
    var oldvalue = parseFloat(margin_input.val());
    distribution_calculate_margin(margin_input, price_input, buy_price_input);
    var newvalue = parseFloat(margin_input.val());
    if (newvalue != oldvalue) {
      p.find('#product_default_margin_percentage').attr('checked', null);
      p.find('#product_margin_percentage').get(0).disabled = false;
    }
  }
}

/* ----- ends our products stuff  ----- */

/* ----- order stuff  ----- */

function distribution_order_products_toggle(fields, toggle) {
  jQuery.each(fields, function(index, field) {
    p = jQuery(field).parents('.order-session-product');
    p.toggle(toggle);
    //v = p.is(':visible');
    //toggle ? (!v ? p.fadeIn() : 0) : (v ? p.fadeOut() : 0);
  });
}

function distribution_order_filter_products(text) {
  text = text.toLowerCase();
  fields = jQuery('#session-column .box-view .box-field.product');
  results = jQuery.grep(fields, function(field, index) {
    fieldText = jQuery(field).text().toLowerCase();
    supplierText = jQuery(field).parents('.supplier-table').find('.supplier').text().toLowerCase();

    matchField = fieldText.indexOf(text) > -1;
    matchSupplier = supplierText.indexOf(text) > -1;
    return matchField || matchSupplier;
  });
  jQuery('#session-column .supplier-table').show();
  distribution_order_products_toggle(jQuery(fields), false);
  distribution_order_products_toggle(jQuery(results), true);

  jQuery('#session-column .supplier-table').each(function(index, supplier) {
    jQuery(supplier).toggle(jQuery(supplier).find('.order-session-product:visible').length > 0 ? true : false);
  });
}

function distribution_order_filter() {
  distribution_order_filter_products(jQuery(this).text());
  jQuery(this).parents('#order-filter').find('input').val(jQuery(this).text());
}

/* ----- ends order stuff  ----- */

/* ----- supplier stuff  ----- */

function distribution_supplier_toggle_edit(context) {
  p = jQuery(context).parents('.supplier');
  if (p.length == 0) {
    p = jQuery('#supplier-add');
    p.show();
  } else {
    p.find('.supplier-view').toggle();
  }
  p.find('.supplier-edit').toggle();
}

/* ----- ends supplier stuff  ----- */

/* ----- session editions stuff  ----- */

function distribution_session_product_pmsync(context, to_price) {
  p = jQuery(context).parents('.session-product-edit');
  margin = p.find('#product_margin_percentage');
  price = p.find('#product_price');
  buy_price = p.find('#product_buy_price');
  if (to_price)
    distribution_calculate_price(price, margin, buy_price);
  else
    distribution_calculate_margin(margin, price, buy_price);
}

/* ----- ends session editions stuff  ----- */

/* ----- toggle edit stuff  ----- */

function distribution_in_session_order_toggle_edit() {
  editing().find('.box-edit').toggle(isEditing());
  distribution_edit_arrow_toggle(editing, isEditing());
}
function distribution_our_product_add() {
  editing = jQuery();
  distribution_value_row_toggle_edit();
  editing = jQuery('#our-product-add');
  distribution_value_row_toggle_edit();
}
function distribution_our_product_toggle_edit() {
  editing().find('.box-view').toggle(!isEditing());
  editing().find('.box-edit').toggle(isEditing());
}
function distribution_session_product_edit() {
  editing().find('.box-edit').toggle(isEditing());
}
function distribution_order_session_product_toggle() {
  editing().find('.box-edit').toggle(isEditing());
  editing().find('.quantity-label').toggle(!isEditing());
  editing().find('.quantity-entry').toggle(isEditing());
}
function distribution_ordered_product_edit() {
  editing().find('.more-actions').toggle(isEditing());
  if (isEditing())
    editing().find('.product-quantity input').focus();
}

/* ----- ends toggle edit stuff  ----- */

function distribution_value_row_toggle_edit() {
  editing().toggleClass('edit');
  eval(editing().attr('toggleedit'));
}
function distribution_value_row_reload() {
  _editing.removeClass('edit hover');
  _isEditing = false;
  _editing = jQuery();
}
function distribution_locate_value_row(context) {
  return jQuery(context).hasClass('value-row') ? jQuery(context) : jQuery(context).parents('.value-row');
}

jQuery(document).click(function(event) {
  if (jQuery(event.target).parents('.more-actions').length > 0) //came from anchor click!
    return false;
  var out = distribution_locate_value_row(event.target).length == 0;
  if (out && isEditing()) {
    distribution_value_row_toggle_edit();
    if (_editing.length > 1)
      setEditing(jQuery(_editing[1]));
    else
      setEditing(jQuery());
    return false;
  }
  return true;
});
jQuery(document).ready(function() {
  if (window.location.hash == '#our-product-add')
    distribution_our_product_add();
});
jQuery('.plugin-distribution .value-row').live('click', function (event) {
  var value_row = distribution_locate_value_row(event.target);
  var now_isInner = value_row.length > 1;

  var isToggle = (jQuery(event.target).hasClass('box-edit-link') && !isEditing) || 
    jQuery(event.target).hasClass('toggle-edit') || jQuery(event.target).parents().hasClass('toggle-edit');
  var isAnother = value_row.get(0) != editing().get(0) || (now_isInner && !_isInner);
  if (now_isInner && !_isInner)
    setEditing(value_row);
  _isInner = now_isInner;

  if (isToggle) {
    if (isAnother) 
      distribution_value_row_toggle_edit();
    setEditing(value_row);
    distribution_value_row_toggle_edit();

    return false;
  } else if (isAnother || !isEditing()) {
    if (isEditing())
      distribution_value_row_toggle_edit();
    setEditing(value_row);
    if (!isEditing())
      distribution_value_row_toggle_edit();

    return false;
  }

  return true;
});
jQuery('.plugin-distribution .value-row').live('mouseenter', function () {
  jQuery(this).addClass('hover');
});
jQuery('.plugin-distribution .value-row').live('mouseleave', function () {
  jQuery(this).removeClass('hover');
});


function distribution_currency(value) {
  return parseFloat(value).toFixed(2);
}

(function($) {
  $.fn.toggleDisabled = function() {
    return this.each(function() { 
      this.disabled = !this.disabled;
    });
  };
})(jQuery);

jQuery('.plugin-distribution input[type=checkbox]').live('change', function () {
  jQuery(this).attr('checked', this.checked ? 'checked' : null);
  return false;
});

Array.prototype.diff = function(a) {
  return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};
Array.prototype.sum = function(){
  for(var i=0,sum=0;i<this.length;sum+=this[i++]);
    return sum;
}
Array.prototype.max = function(){
  return Math.max.apply({},this)
}
Array.prototype.min = function(){
  return Math.min.apply({},this)
}


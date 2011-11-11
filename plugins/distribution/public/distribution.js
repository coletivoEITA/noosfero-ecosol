var _editing = jQuery();
var _inner_editing = jQuery();
var _isInner = false;

function setEditing(value) {
  _editing = jQuery(value);
}
function editing() {
  return _editing.first();
}
function isEditing() {
  return editing().first().hasClass('edit');
}

function distribution_edit_arrow_toggle(arrow, toggle) {
  arrow = jQuery(arrow);
  if (!arrow.hasClass('actions-circle'))
    arrow = arrow.find('.actions-circle');

  arrow.toggleClass('edit', toggle);
  return arrow.hasClass('edit');
}


function distribution_calculate_price(price_input, margin_input, base_price_input) {
  var price = parseFloat(jQuery(price_input).val());
  var base_price = parseFloat(jQuery(base_price_input).val());
  var margin = parseFloat(jQuery(margin_input).val());

  var value = distribution_currency( base_price + (margin / 100) * base_price );
  jQuery(price_input).val( isNaN(value) ? base_price_input.val() : value );
}
function distribution_calculate_margin(margin_input, price_input, base_price_input) {
  var price = parseFloat(jQuery(price_input).val());
  var base_price = parseFloat(jQuery(base_price_input).val());
  var margin = parseFloat(jQuery(margin_input).val());

  var value = distribution_currency( ((price - base_price) / base_price ) * 100 );
  jQuery(margin_input).val( isFinite(value) ? value : '' );
}

/* ----- session stuff  ----- */

function distribution_in_session_order_toggle(context) {
  container = jQuery(context).hasClass('session-orders') ? jQuery(context) : jQuery(context).parents('.session-orders');
  container.toggleClass('show');
  container.find('.order-content').toggle();
  distribution_edit_arrow_toggle(container);
}

/* ----- ends session stuff  ----- */

/* ----- our products stuff  ----- */

function distribution_our_product_toggle_referred(context) {
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
}
function distribution_our_product_sync_referred(context) {
  var p = jQuery(context).parents('.box-edit');
  var referred = p.find('#'+context.id.replace('product_supplier_product', 'product')).get(0);
  if (referred && referred.disabled) {
    jQuery(referred).val(jQuery(context).val());

    if (referred.onkeyup)
      referred.onkeyup();
  }
}
function distribution_our_product_add_missing_products(context, url) {
  supplier = jQuery('#our-product-add').find('#product_supplier_id');
  jQuery.post(url, jQuery(supplier).serialize(), function() {
  });
}
function distribution_our_product_add_change_supplier(context, url) {
  jQuery('#our-product-add').load(url, jQuery(context).serialize(), function() {
    distribution_our_product_toggle_edit();
  });
}
function distribution_our_product_add_from_product(context, url, data) {
  jQuery('#our-product-add').load(url, data, function() {
    distribution_our_product_toggle_edit();
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
      var checked = newvalue == parseFloat(margin_input.attr('defaultvalue'));
      p.find('#product_default_margin_percentage').attr('checked', checked ? 'checked' : null);
      p.find('#product_margin_percentage').get(0).disabled = checked;
    }
  }
}

function distribution_our_product_css_align() {
  var supplied = editing().find('.our-product-supplied-column');
  var distributed = editing().find('.our-product-distributed-column');
  if (supplied.length > 0)
    supplied.find('.price-block').css('top', distributed.find('.price-block').position().top);
  //var use_original = editing().find('.our-product-use-original-column');
  //use_original.find('input[type=checkbox]').each(function(index, checkbox) {
    //jQuery(checkbox).css('top', distributed.position().top - jQuery(jQuery(checkbox).attr('for')).first().position().top);
  //});
}

/* ----- ends our products stuff  ----- */

/* ----- order stuff  ----- */

function distribution_order_products_toggle(fields, toggle) {
  jQuery.each(fields, function(index, field) {
    var p = jQuery(field).parents('.order-session-product');
    p.toggle(toggle);
    //v = p.is(':visible');
    //toggle ? (!v ? p.fadeIn() : 0) : (v ? p.fadeOut() : 0);
  });
}

function distribution_order_filter_products(text) {
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
  distribution_order_products_toggle(jQuery(fields), false);
  distribution_order_products_toggle(jQuery(results), true);

  jQuery('#session-products-for-order .supplier-table').each(function(index, supplier) {
    jQuery(supplier).toggle(jQuery(supplier).find('.order-session-product:visible').length > 0 ? true : false);
  });
}

function distribution_order_filter() {
  distribution_order_filter_products(jQuery(this).text());
  jQuery(this).parents('#order-filter').find('input').val(jQuery(this).text());
}

/* ----- ends order stuff  ----- */

/* ----- supplier stuff  ----- */

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

function distribution_supplier_add_link() {
  if (isEditing())
    distribution_value_row_toggle_edit();
  setEditing(jQuery('#supplier-add'));
  distribution_value_row_toggle_edit();
}
function distribution_supplier_toggle_edit() {
  if (editing().is('#supplier-add'))
    editing().toggle(isEditing());
  editing().find('.box-view').toggle(!isEditing());
  editing().find('.box-edit').toggle(isEditing());
}
function distribution_in_session_order_toggle_edit() {
  editing().find('.box-edit').toggle(isEditing());
  distribution_edit_arrow_toggle(editing, isEditing());
}
function distribution_our_product_add_link() {
  if (isEditing())
    distribution_value_row_toggle_edit();
  setEditing(jQuery('#our-product-add'));
  distribution_value_row_toggle_edit();
}
function distribution_our_product_toggle_edit() {
  if (editing().is('#our-product-add'))
    editing().toggle(isEditing());
  editing().find('.box-view').toggle(!isEditing());
  editing().find('.box-edit').toggle(isEditing());

  distribution_our_product_css_align();
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
  if (!isEditing()) {
    if (_editing.length > 1)
      setEditing(jQuery(_editing[1]));
    else
      setEditing(jQuery());
  }
}
function distribution_value_row_reload() {
  distribution_value_row_toggle_edit();
}
function distribution_locate_value_row(context) {
  return jQuery(context).hasClass('value-row') ? jQuery(context) : jQuery(context).parents('.value-row');
}

function target_isToggle(target) {
  return (jQuery(target).hasClass('box-edit-link') && !isEditing()) || 
    jQuery(target).hasClass('toggle-edit') || jQuery(target).parents().hasClass('toggle-edit');
}
jQuery(document).click(function(event) {
  if (jQuery(event.target).parents('.more-actions').length > 0) //came from anchor click!
    return false;
  var isToggle = target_isToggle(event.target);
  var out = distribution_locate_value_row(event.target).length == 0;
  if (!isToggle && out && isEditing()) {
    distribution_value_row_toggle_edit();
    return false;
  }
  return true;
});
jQuery(document).ready(function() {
  el = jQuery(window.location.hash);
  if (el.hasClass('value-row')) {
    setEditing(el);
    distribution_value_row_toggle_edit();
  }
});
jQuery('.plugin-distribution .value-row').live('click', function (event) {
  var value_row = distribution_locate_value_row(event.target);
  var now_isInner = value_row.length > 1;

  var isToggle = target_isToggle(event.target);
  var isAnother = value_row.get(0) != editing().get(0) || (now_isInner && !_isInner);
  if (now_isInner && !_isInner)
    setEditing(value_row);
  _isInner = now_isInner;

  if (!isToggle && value_row.attr('without-click-edit') != undefined)
    return;

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
  if (jQuery(this).attr('without-hover') != undefined)
    return;
  jQuery(this).addClass('hover');
});
jQuery('.plugin-distribution .value-row').live('mouseleave', function () {
  if (jQuery(this).attr('without-hover') != undefined)
    return;
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


var editing = jQuery();
var clicked = jQuery();


function distribution_edit_arrow_toggle(arrow, toggle) {
  arrow = jQuery(arrow);
  if (!arrow.hasClass('actions-circle'))
    arrow = arrow.find('.actions-circle');

  arrow.toggleClass('edit', toggle);
  return arrow.hasClass('edit');
}


function distribution_order_session_product_toggle(el, selected) {
  el.find('.value-row').toggleClass('clicked', selected);
  el.find('.more-info').toggle(selected);
  el.find('.quantity-label').toggle(!selected);
  el.find('.quantity-entry').toggle(selected);
}
function distribution_order_session_product_click() {
  it = jQuery(this);
  if (clicked == it)
    return false;
  distribution_order_session_product_toggle(clicked, false);
  distribution_order_session_product_toggle(it, true);
  clicked = it;

  return false;
}

jQuery(document).click(function(event) {
  if (jQuery(event.target).parents('.more-actions').length > 0) //came from anchor click!
    return;
  distribution_order_session_product_toggle(clicked, false);
});
function distribution_order_session_product_hover() {
  jQuery(this).find('.value-row').toggleClass('selected');
}
function distribution_ordered_product_hover() {
  jQuery(this).toggleClass('selected');
  jQuery(this).find('.more-actions').toggle();
}


function distribution_our_product_toggle_referred(context) {
  p = jQuery(context).parents('.our-product-edit');
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
  });
}

function distribution_our_product_sync_referred(context) {
  p = jQuery(context).parents('.our-product-edit');
  referred = p.find('#'+context.id.replace('product_supplier_product', 'product')).get(0);
  if (referred && referred.disabled)
    jQuery(referred).val(jQuery(context).val());
}
jQuery(document).ready(function() {
  if (window.location.hash == '#our-product-add')
    distribution_our_product_toggle_edit();
});

function distribution_our_product_toggle_edit(context) {
  row = jQuery(context).hasClass('our-product') ? jQuery(context) : jQuery(context).parents('.our-product');
  if (!row.length)
    row = jQuery('#our-product-add');
  row.find('.our-product-view').toggle();
  row.find('.our-product-edit').toggle();
  row.toggleClass('edit');
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


function distribution_plugin_session_order_toggle_edit(context) {
  if (context != null) {
    newEditing = jQuery(context).parents('.in-session-order');

    newEditing.find('.in-session-order-edit').toggle(true);
    newEditing.toggleClass('edit', true);
    distribution_edit_arrow_toggle(editing, true);
  } else
    newEditing = jQuery();

  editing.find('.in-session-order-edit').toggle(false);
  editing.toggleClass('edit', false);
  distribution_edit_arrow_toggle(editing, false);

  editing = newEditing.get(0) === editing.get(0) ? jQuery() : newEditing;
  
}

function distribution_plugin_session_product_edit(context) {
  editing = jQuery(context).hasClass('session-product') ? jQuery(context) : jQuery(context).parents('.session-product');

  toggle = !editing.hasClass('edit');

  editing.toggleClass('edit', toggle);
  editing.find('.session-product-edit').toggle(toggle);
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


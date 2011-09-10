function sessionProductSetFocus(id) {
  jQuery(id).find('input').focus();
}

function distribution_order_session_product_toggle(el, selected) {
  el.find('.value-row').toggleClass('clicked', selected);
  el.find('.session-product-more-info').toggle(selected);
  el.find('.quantity-label').toggle(!selected);
  el.find('.quantity-entry').toggle(selected);
}
var clicked = jQuery();
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
  if (jQuery(event.target).parents('.ordered-product-more-actions').length > 0) //came from anchor click!
    return;
  distribution_order_session_product_toggle(clicked, false);
});

function distribution_order_session_product_hover() {
  jQuery(this).find('.value-row').toggleClass('selected');
}

function distribution_ordered_product_hover() {
  jQuery(this).toggleClass('selected');
  jQuery(this).find('.ordered-product-more-actions').toggle();
}

function distribution_our_product_enabled_refered(context, refered, options) {
  refered = jQuery(context).parents('.our-product-distributed-column').find(refered);
  refered.get(0).disabled = context.checked;
  if (options.clean && context.checked)
    refered.val('');
  return refered;
}

function distribution_our_product_toggle_edit(context) {
  row = jQuery(context).parents('.value-row');
  row.find('.our-product-view').toggle();
  row.find('.our-product-edit').toggle();
  row.toggleClass('edit');
}

function distribution_node_margin_toggle_edit(content) {
  c = jQuery('#node-margin-percentage');
  i = c.find('input[type=text]');
  c.toggleClass('edit view');
  c.find('.toggle-button').toggle();
  i.toggleDisabled();
  c.toggleClass('empty', i.val().empty());
  c.toggleClass('non-empty', !i.val().empty());
}

var distribution_session_product_editing = jQuery();
function distribution_plugin_session_product_edit(id) {
  editing = jQuery(id);
  stop_editing = editing.index(distribution_session_product_editing) ? false : true;

  distribution_session_product_editing.removeClass('session-product-editing');
  distribution_session_product_editing.find('.session-product-edit').hide();
  if (!stop_editing) {
    editing.addClass('session-product-editing');
    editing.find('.session-product-edit').show();
    distribution_session_product_editing = editing;
  }
}

(function($) {
  $.fn.toggleDisabled = function() {
    return this.each(function() { 
      this.disabled = !this.disabled;
    });
  };
})(jQuery);


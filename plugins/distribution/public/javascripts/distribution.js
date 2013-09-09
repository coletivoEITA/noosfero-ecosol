distribution = {

  /* ----- header ----- */

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

  /* ----- session ----- */

  in_session_order_toggle: function (context) {
    container = jQuery(context).hasClass('session-orders') ? jQuery(context) : jQuery(context).parents('.session-orders');
    container.toggleClass('show');
    container.find('.order-content').toggle();
    sortable_table.edit_arrow_toggle(container);
  },

  /* ----- order ----- */

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

  /* ----- session editions ----- */

  offered_product: {

    pmsync: function (context, to_price) {
      p = jQuery(context).parents('.session-product .box-edit');
      margin = p.find('#product_margin_percentage');
      price = p.find('#product_price');
      buy_price = p.find('#product_buy_price');
      original_price = p.find('#product_original_price');
      base_price = unlocalize_currency(buy_price.val()) ? buy_price : original_price;

      if (to_price)
        suppliers.price.calculate(price, margin, base_price);
      else
        suppliers.margin.calculate(margin, price, base_price);
    },

  },

  /* ----- toggle edit ----- */

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

  colorbox: function (options) {
    options.innerWidth = 500;
    jQuery.colorbox(options);
  },

  ajaxifyPagination: function(elementId) {
    jQuery(".pagination a").click(function() {
      loading_overlay.show(elementId);
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

/* ----- infrastructure ----- */

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


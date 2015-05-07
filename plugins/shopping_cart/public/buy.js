shopping_cart.buy = {

  validate: function() {
    jQuery("#cart-request-form").validate({
      submitHandler: function(form) {
        jQuery(form).find('input.submit').attr('disabled', true);
        jQuery('#cboxLoadingOverlay').show().addClass('loading');
        jQuery('#cboxLoadingGraphic').show().addClass('loading');
      }
    });
  },

  update_delivery: function () {
    jQuery('#cboxLoadingGraphic').show();
    var me = jQuery(this);
    var profile = me.attr('data-profile-identifier');
    var id = me.val();
    var name = me.find('option:selected').attr('data-label');
    jQuery.ajax({
      url: '/plugin/shopping_cart/update_supplier_delivery',
      dataType: "json",
      data: 'supplier_delivery_id='+id,
      success: function(data, st, ajax) {
        jQuery('#delivery-price').text(data.delivery_price);
        jQuery('.cart-table-total-value').text(data.total_price);
        jQuery('#delivery-name').text(name);
        jQuery('#cboxLoadingGraphic').hide();
      },
      error: function(ajax, st, errorThrown) {
        alert('Update delivery option - HTTP '+st+': '+errorThrown);
      },
    });
  },

  update_payment: function() {
    var payment = jQuery(this)
    var form = jQuery(payment.get(0).form)
    var changeField = form.find('#customer_change').parents('.form-group');
    var method = payment.val() == 'money' ? 'slideDown' : 'slideUp';
    changeField[method]('fast');
  },
}

jQuery(document).ready(shopping_cart.buy.validate)
jQuery('#supplier_delivery_id').on('change keyup', shopping_cart.buy.update_delivery)
jQuery('#customer_payment').on('change keyup', shopping_cart.buy.update_payment)


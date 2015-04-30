jQuery(document).ready(function(){
  jQuery("#cart-request-form").validate({
    submitHandler: function(form) {
      jQuery(form).find('input.submit').attr('disabled', true);
      jQuery('#cboxLoadingOverlay').show().addClass('loading');
      jQuery('#cboxLoadingGraphic').show().addClass('loading');
    }
  });
});

jQuery('#supplier_delivery_id').change(function(){
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
});

jQuery('#customer_payment').change(function(){
  var changeField = jQuery(this).parents('.formfieldline').next();
  var method = jQuery(this).val() == 'money' ? 'slideDown' : 'slideUp';
  changeField[method]('fast');
});


suppliers = {

  add_link: function () {
    if (toggle_edit.isEditing())
      toggle_edit.value_row.toggle_edit();
    toggle_edit.setEditing(jQuery('#supplier-add'));
    toggle_edit.value_row.toggle_edit();
  },

  toggle_edit: function () {
    if (toggle_edit.editing().is('#supplier-add'))
      toggle_edit.editing().toggle(toggle_edit.isEditing());
    toggle_edit.editing().find('.box-view').toggle(!toggle_edit.isEditing());
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
  },

  our_product: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    },

    load: function(el) {
      // load default logic
      el.find('#product_default_margin_percentage').get(0).onchange();
      // click
      el.find('.properties-block').click(suppliers.our_product.enable_if_disabled);
    },

    enable_if_disabled: function (event) {
      target = jQuery(event.target);
      if (target.is('input[type=text][disabled], select[disabled]')) {
        product = jQuery(target).parents('.our-product');
        default_checkbox = jQuery(jQuery.grep(product.find('input[type=checkbox][for]'), function(element, index) {
          return jQuery(element).attr('for').indexOf(target.attr('id')) >= 0;
        }));
        default_checkbox.attr('checked', null);
        suppliers.our_product.toggle_referred(default_checkbox);
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
        suppliers.our_product.toggle_edit();
      });
    },
    add_from_product: function (context, url, data) {
      suppliers.setLoading('our-product-add');
      jQuery('#our-product-add').load(url, data, function() {
        suppliers.our_product.toggle_edit();
      });
      distribution.unsetLoading('our-product-add');
    },
  },
};

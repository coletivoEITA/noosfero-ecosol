
suppliers = {

  add_link: function () {
    if (toggle_edit.isEditing())
      toggle_edit.value_row.toggle_edit();

    var supplier_add = jQuery('#supplier-add');
    toggle_edit.setEditing(supplier_add);
    toggle_edit.value_row.toggle_edit();
  },

  toggle_edit: function () {
    if (toggle_edit.editing().is('#supplier-add'))
      toggle_edit.editing().toggle(toggle_edit.isEditing());
    toggle_edit.editing().find('.box-view').toggle(!toggle_edit.isEditing());
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
  },

  add: {
    supplier_added: function () {
      jQuery('#results').html('');
    },
    create_dummy: function () {
      jQuery('#find-enterprise, #create-dummy, #create-dummy .box-edit').toggle();
    },

    search: function (input) {
      query = jQuery(input).val();
      if (query.length < 3)
        return;
      input.form.onsubmit();
    },
  },

  our_product: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    },

    default_change: function (event) {
      block = jQuery(this).parents('.block');
      block.find('div[data-non-defaults]').toggle(!this.checked);
    },

    load: function(id) {
      jQuery('#our-product-'+id+' div[data-default-toggle] input').change(suppliers.our_product.default_change).change();
    },

    pmsync: function (context, to_price) {
      var p = jQuery(context).parents('.our-product');
      var margin_input = p.find('.product-margin-percentage');
      var price_input = p.find('.product-price');
      var buy_price_input = p.find('.product-base-price');

      if (to_price)
        suppliers.price.calculate(price_input, margin_input, buy_price_input);
      else
        suppliers.margin.calculate(margin_input, price_input, buy_price_input);
    },
  },

  price: {

    calculate: function (price_input, margin_input, base_price_input) {
      var price = unlocalize_currency(jQuery(price_input).val());
      var base_price = unlocalize_currency(jQuery(base_price_input).val());
      var margin = unlocalize_currency(jQuery(margin_input).val());

      var value = base_price + (margin / 100) * base_price;
      if (isNaN(value))
        value = unlocalize_currency(base_price_input.val());
      jQuery(price_input).val(localize_currency(value));
    },
  },

  margin: {

    calculate: function (margin_input, price_input, base_price_input) {
      var price = unlocalize_currency(jQuery(price_input).val());
      var base_price = unlocalize_currency(jQuery(base_price_input).val());
      var margin = unlocalize_currency(jQuery(margin_input).val());

      var value = ((price - base_price) / base_price ) * 100;
      value = !isFinite(value) ? '' : localize_currency(value);
      jQuery(margin_input).val(value);
    },
  },

};


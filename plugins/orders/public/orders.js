
orders = {

  product_edit: function () {
    toggle_edit.editing().find('.more-actions').toggle(toggle_edit.isEditing());
    if (toggle_edit.isEditing())
      toggle_edit.editing().find('.product-quantity input').focus();
  },

};

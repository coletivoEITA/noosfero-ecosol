
orders = {

  product_edit: function () {
    toggle_edit.editing().find('.more-actions').toggle(toggle_edit.isEditing());
    if (toggle_edit.isEditing())
      toggle_edit.editing().find('.product-quantity input').focus();
  },

  admin: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
      sortable_table.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
    },
  },

};

if (typeof toggle_edit === 'undefined') {

toggle_edit = {

  _editing: jQuery(),
  _isInner: false,

  setEditing: function (value) {
    toggle_edit._editing = jQuery(value);
  },
  editing: function () {
    return toggle_edit._editing.first();
  },
  isEditing: function () {
    return toggle_edit.editing().first().hasClass('edit');
  },

  target: {
    isToggle: function (target) {
      return (jQuery(target).hasClass('box-edit-link') && !toggle_edit.isEditing()) ||
        jQuery(target).hasClass('toggle-edit') || jQuery(target).parents().hasClass('toggle-edit');
    },
    isToggleIgnore: function (target) {
      return jQuery(target).hasClass('toggle-ignore') || jQuery(target).parents().hasClass('toggle-ignore');
    },
  },

  document_click: function(event) {
    if (toggle_edit.target.isToggleIgnore(event.target))
      return;

    var isToggle = toggle_edit.target.isToggle(event.target);
    var out = toggle_edit.value_row.locate(event.target).length == 0;
    if (!isToggle && out && toggle_edit.isEditing()) {
      toggle_edit.value_row.toggle_edit();
      return false;
    }
    return true;
  },

  open_anchor: function () {
    el = jQuery(window.location.hash);
    toggle_edit.value_row.reload();
    if (el.hasClass('value-row')) {
      toggle_edit.setEditing(el);
      toggle_edit.value_row.toggle_edit();
    }
  },

  value_row: {

    locate: function (context) {
      return jQuery(context).hasClass('value-row') ? jQuery(context) : jQuery(context).parents('.value-row');
    },

    mouseenter: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).addClass('hover');
    },

    mouseleave: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).removeClass('hover');
    },

    click: function (event) {
      if (toggle_edit.target.isToggleIgnore(event.target))
        return true;

      var value_row = toggle_edit.value_row.locate(event.target);
      var now_isInner = value_row.length > 1;
      var isToggle = toggle_edit.target.isToggle(event.target);
      var isAnother = value_row.get(0) != toggle_edit.editing().get(0) || (now_isInner && !toggle_edit._isInner);
      if (now_isInner && !toggle_edit._isInner)
        toggle_edit.setEditing(value_row);
      toggle_edit._isInner = now_isInner;

      if (!isToggle && value_row.attr('without-click-edit') != undefined)
        return;

      if (isToggle) {
        if (isAnother)
          toggle_edit.value_row.toggle_edit();
        toggle_edit.setEditing(value_row);
        toggle_edit.value_row.toggle_edit();

        return false;
      } else if (isAnother || !toggle_edit.isEditing()) {
        if (toggle_edit.isEditing())
          toggle_edit.value_row.toggle_edit();
        toggle_edit.setEditing(value_row);
        if (!toggle_edit.isEditing())
          toggle_edit.value_row.toggle_edit();

        return false;
      }

      return true;
    },

    toggle_edit: function () {
      toggle_edit.editing().toggleClass('edit');
      eval(toggle_edit.editing().attr('toggleedit'));
      if (!toggle_edit.isEditing()) {
        if (toggle_edit._editing.length > 1)
          toggle_edit.setEditing(jQuery(toggle_edit._editing[1]));
        else
          toggle_edit.setEditing(jQuery());
      }
    },
    reload: function () {
      toggle_edit.value_row.toggle_edit();
    },
  },
};

jQuery('.value-row').live('mouseenter', toggle_edit.value_row.mouseenter);
jQuery('.value-row').live('mouseleave', toggle_edit.value_row.mouseleave);
jQuery('.value-row').live('click', toggle_edit.value_row.click);
jQuery(document).click(toggle_edit.document_click);
jQuery(document).ready(toggle_edit.open_anchor);
jQuery(window).bind('hashchange', toggle_edit.open_anchor);

}

if (typeof sortable_table === 'undefined') {

sortable_table = {

  header_click: function () {
    this.ascending = !this.ascending;
    column = jQuery(this);
    header = column.parents('.table-header');
    content = header.siblings('.table-content');
    jQuerySort(content.children('.value-row'), {find: '.'+this.classList[1], ascending: this.ascending});

    arrow = header.find('.sort-arrow').length > 0 ? header.find('.sort-arrow') : jQuery('<div class="sort-arrow"/>').appendTo(header);
    arrow.toggleClass('desc', !this.ascending).css({
      top: column.position().top,
      left: column.position().left + parseInt(column.width())/2 +
        parseInt(column.css('margin-left')) + parseInt(column.css('padding-left'))
    });
  },

  edit_arrow_toggle: function (context, toggle) {
    arrow = jQuery(context).hasClass('actions-circle') ? jQuery(context) : jQuery(context).find('.actions-circle');

    hide = arrow.find('.action-hide').toggle(toggle);
    show = arrow.find('.action-show').toggle(!toggle);
    return hide.is(':visible');
  },

},

jQuery('.sortable-table .table-header .box-field').live('click', sortable_table.header_click);

}

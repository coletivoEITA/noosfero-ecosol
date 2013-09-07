if (typeof sortable_table === 'undefined') {

sortable_table = {

  header_click: function () {
    this.ascending = !this.ascending;
    header = jQuery(this).parents('.table-header');
    content = header.siblings('.table-content');
    jQuerySort(content.children('.value-row'), {find: '.'+this.classList[1], ascending: this.ascending});

    arrow = header.find('.sort-arrow').length > 0 ? header.find('.sort-arrow') : jQuery('<div class="sort-arrow"/>').appendTo(header);
    arrow.toggleClass('desc', !this.ascending).css({
      top: jQuery(this).position().top + jQuery(this).height() - 1,
      left: jQuery(this).position().left + parseInt(jQuery(this).css('margin-left')) + parseInt(jQuery(this).css('padding-left'))
    });
  },

},

jQuery('.sortable-table .table-header .box-field').live('click', sortable_table.header_click);

}

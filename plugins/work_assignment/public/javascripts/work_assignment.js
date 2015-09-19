//= require_self
//= require ./submission
//= require ./submissions

window.work_assignment = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'work_assignment_plugin'}))
  },

  folder: {

    load: function () {
      this.loadButtons()
      this.table.load()
    },

    loadButtons: function () {
      $(".view-author-versions").each(function(index, bt) {
        bt.onclick = function () {
          var folderId = this.getAttribute("data-folder-id");
          var tr = $(".submission-from-"+folderId);
          tr.toggle()
        }
      });
    },

    table: {
      submissions: [],

      detail: {

        mount: function(index, row, detail) {
          var id = row._data.id
          var submissions = work_assignment.folder.table.submissions[parseInt(id)]
          var tag = $('<submissions>').get(0)
          $(detail).append(tag)
          riot.mount(tag, {submissions: submissions})
        },
      },

      load: function () {
        $('#authors-submissions').bootstrapTable({
          striped: true,

          toolbar: '#toolbar',
          search: true,
          detailView: true,
          onExpandRow: this.detail.mount,

          columns: [
            {field: 'author', sortable: true},
            {field: 'submissionDate', sortable: true},
            {field: 'versions', sortable: false},
            {field: 'actions', sortable: false},
          ],
        })

        $(document).ready(function () {
          $('[data-toggle="tooltip"]').tooltip()
        })

      },
    },
  },
}


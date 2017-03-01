
window.web_odf = {

  routes: {
    edition: Routes.web_odf_plugin_edition_path,
    view: Routes.web_odf_plugin_view_path,
  },

  edit: {
    editor: null,

    file: function (id, userFullName) {
      Wodo.createTextEditor('webodf-editor', {
        allFeaturesEnabled: true,
        userData: { fullName: userFullName },
      }, function (err, editor) {
        if (err) { console.log(err); return }

        this.hook(editor)
        var url = web_odf.routes.edition({profile: noosfero.profile, action: 'file'})+'/'+id
        editor.openDocumentFromUrl(url, function (err) {
          if (err) { console.log(err); return }
        }.bind(this))
      }.bind(this))
    },

    hook: function (editor) {
      this.editor = editor
      $('form[class="WebODFPlugin::Document"]').submit(function () {
        var field = $('#article_body').get(0)
        this.editor.getDocumentAsByteArray(function (err, odtFileAsByteArray) {
          if (err) { console.log(err); return }
          field.value = odtFileAsByteArray
        })
        
        return true
      }.bind(this))
    },
  },

  view: {
    canvas: null,

    file: function (id) {
      var element = $('#odf').get(0)
      this.canvas = new odf.OdfCanvas(element);
      var url = web_odf.routes.view({profile: noosfero.profile, action: 'file'})+'/'+id
      this.canvas.load(url)
    },
  },

}


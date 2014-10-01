
noosfero.tinymce = {

  defaultOptions: {
    mode: "textareas", //necessary for compat3x
    theme: "modern",
    relative_urls: false,
    remove_script_host: false,
    extended_valid_elements: "applet[style|archive|codebase|code|height|width],comment,iframe[src|style|allowtransparency|frameborder|width|height|scrolling],embed[title|src|type|height|width],audio[controls|autoplay],video[controls|autoplay],source[src|type]",
    entity_encoding: 'raw',
    setup: function(editor) {
      tinymce_macros_setup(editor)
    },
  },

  init: function(_options) {
    var options = jQuery.extend({}, this.defaultOptions, _options)
    tinymce.init(options);
    jQuery('.mceEditor').tinymce(options);

    jQuery('form').bind('form-pre-serialize', function(e) {
      for (var ed in tinymce.editors)
        ed.save()
    });

  },
};

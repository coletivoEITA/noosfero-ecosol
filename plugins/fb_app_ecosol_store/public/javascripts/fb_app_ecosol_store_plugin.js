fb_app_ecosol_store = {

  autocomplete: function() {
    jQuery('[name=fb_store]').autocomplete({
      source: function(request,response){
        jQuery.ajax('/plugin/fb_app_ecosol_store/search',{
          data: {
            query: request
          },

          dataType: 'json',
          type: 'GET',
          success: function(data) {
            var i, names;
            names = [];
            for (i in data) {
              names.push(data[i]['name'])
            }
            response(names)
          },
          error: function() {
            alert('Erro!')
          }
        });
      }
    });
  },

  addJS: function(url) {
    var script = document.createElement('script'); script.type = 'text/javascript'; script.src = url;
    document.getElementsByTagName('head')[0].appendChild(script);
  },

  init_admin: function() {
    if (jQuery('#fb_store_admin_page').length > 0) {
        this.init_integration_type_selection();
        this.autocomplete();
        this.redraw_tabela_empreendimentos();
    }
  },

  init_integration_type_selection: function() {
      var func_on_radio_change;

      func_on_radio_change = function(evt) {
        var radio_elements = jQuery('[name=fb_integration_type]')

        radio_elements.each(function(key,elm) {
            if (elm.checked) {
                jQuery('#fb_integration_type_'+elm.value).show()
            } else {
                jQuery('#fb_integration_type_'+elm.value).hide()
            }
        })
      };

      jQuery('[name=fb_integration_type]').each(function(key,radio_elm) {
        var $radio_elm = jQuery(radio_elm)
        $radio_elm.on('change',func_on_radio_change);
        $radio_elm.trigger('change')
      })
  },

  redraw_tabela_empreendimentos: function() {
      var i, tbody, tr_html, tr, remove_button, self;
      self = this;
      tbody = jQuery('#fb_tabela_empreendimentos')
      tbody.empty()
      for (i=0;i<empreendimentos.length;i++) {
          tr_html  = '<tr>'
          tr_html += '<td>'+empreendimentos[i].name+'</td>'
          tr_html += '<td class="remove-btn-holder"></td>'
          tr_html += '</tr>'
          tr = jQuery(tr_html);
          tbody.append(tr);
          remove_button = jQuery('<button data-profile-pos="'+i+'">Remover</button>');
          remove_button.on('click',function(evt) {
            var pos = parseInt(jQuery(evt.target).data('profile-pos'))
            empreendimentos.splice(pos,1);
            self.redraw_tabela_empreendimentos();
          });
          tr.find('.remove-btn-holder').append(remove_button);
      }
  }
};

jQuery('document').ready(function(){
  fb_app_ecosol_store.init_admin();
});

fb_app_ecosol_store.addJS('http://dtygel.eita.org.br/lojacirandasfb/utils.js');


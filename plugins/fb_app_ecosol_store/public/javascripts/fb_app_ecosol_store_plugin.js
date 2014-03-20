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

  addJS: function(js) {
    var script = document.createElement('script'); script.type = 'text/javascript'; script.src = 'url';
    document.getElementsByTagName('head')[0].appendChild(script);
  },

};

jQuery('document').ready(function(){
  fb_app_ecosol_store.autocomplete();
});

fb_app_ecosol_store.addJS('http://dtygel.eita.org.br/lojacirandasfb/utils.js');


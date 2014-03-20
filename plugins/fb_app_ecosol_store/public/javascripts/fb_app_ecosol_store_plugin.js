jQuery('document').ready(function(){
    alert('blabla');
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
});

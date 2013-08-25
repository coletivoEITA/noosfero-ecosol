/**
 * Etherpad Lite plug-in for TinyMCE version 3.x
 * @author     Daniel Tygel
 * @version    $Rev: 2 $
 * @package    etherpadlite
 * @link http://cirandas.net/dtygel
 * EtherPad plugin for TinyMCE
 * GPL 3 LICENCES
 */

(function() {
	tinymce.PluginManager.requireLangPack('etherpadlite');
	tinymce.create('tinymce.plugins.EtherPadLitePlugin', {
		init : function(ed, url) {
			var t = this;

			t.editor = ed;
			
			//If the person who activated the plugin didn't put a Pad Server URL, the plugin won't work!
			if (!ed.getParam("plugin_etherpadlite_padServerUrl")) {
				alert(etherpadlite.error);
				return null;
			}
			
			var padUrl = ed.getParam("plugin_etherpadlite_padServerUrl");
			var padPrefix = (ed.getParam("plugin_etherpadlite_padNamesPrefix"))
				? ed.getParam("plugin_etherpadlite_padNamesPrefix")
				: "";
			var padWidth = (ed.getParam("plugin_etherpadlite_padWidth"))
				? ed.getParam("plugin_etherpadlite_padWidth")
				: "100%";
			var padHeight = (ed.getParam("plugin_etherpadlite_padHeight"))
				? ed.getParam("plugin_etherpadlite_padHeight")
				: "400";

			ed.addCommand('mceEtherPadLite', function() {
				var xmlhttp;
		    	if (window.XMLHttpRequest) { // code for IE7+, Firefox, Chrome, Opera, Safari
    			    xmlhttp = new XMLHttpRequest();
    			} else { // code for IE6, IE5
    			    xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    			}
			    xmlhttp.onreadystatechange = function() {
		    	    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		    	    	var padName = xmlhttp.responseText;
						var iframe = "<iframe name='embed_readwrite' src='" + padUrl + padName + "?showControls=true&showChat=true&&alwaysShowChat=true&lang=pt&showLineNumbers=true&useMonospaceFont=false' width='" + padWidth + "' height='" + padHeight + "'></iframe>";

						ed.execCommand('mceInsertContent', false, iframe);
		    	    }
			    }
			    xmlhttp.open("GET", url+"/etherpad_name_generator.php?padPrefix="+padPrefix, true);
    			xmlhttp.send();
			});

			ed.addButton('etherpadlite', {title : 'etherpadlite.desc', cmd : 'mceEtherPadLite', image : url + '/img/etherpadlite.gif'});
		},

		getInfo : function() {
			return {
				longname : 'Insert a collaborative text with Etherpad Lite',
				author : 'Daniel Tygel',
				authorurl : 'http://cirandas.net/dtygel',
				infourl : 'no url yet',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});


	// Register plugin
	tinymce.PluginManager.add('etherpadlite', tinymce.plugins.EtherPadLitePlugin);
})();

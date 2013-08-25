tinyMCEPopup.requireLangPack();

//Here we define which etherpad-lite server we want to use:
var url='http://pad.eita.org.br/p/';
//Here is the prefix for automagically creating new pads in the server:
var padPrefix = 'cirandas-autopad-';

var EtherPadLiteDialog = {
	init : function() {
	},
	insert : function() {
		// Insert the contents from the input into the document
		var f = document.forms[0], size = '', options = '';
		
		//ENABLE CHAT?
		options += '&showChat=';
		switch (f.epChat.value){
	        case '0':
	        	options += 'false';
	        break;
	        case '1':
	        	options += 'true';
            break;
		}
		//CHAT ALWAYS?
		options += '&alwaysShowChat=';
		switch (f.epAlwaysChat.value)        {
	        case '0': 
	        	options += 'false';
	            break;
	        case '1':
	        	options += 'true';
                break;
		}
		//Config Pad Size
		if(f.etherpadliteWidth.value != ''){
			size += ' width='+f.etherpadliteWidth.value;
		}
		if(f.etherpadliteWidth.value != ''){
			size += ' height='+f.etherpadliteHeight.value;
		}
		
		if (f.etherpadliteID.value=='') {
			var xmlhttp;
	    	if (window.XMLHttpRequest) { // code for IE7+, Firefox, Chrome, Opera, Safari
    		    xmlhttp = new XMLHttpRequest();
    		} else { // code for IE6, IE5
    		    xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    		}
		    xmlhttp.onreadystatechange = function() {
	    	    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	    	        insert_pad(xmlhttp.responseText);
	    	    }
		    }
		    xmlhttp.open("GET", "etherpad_name_generator.php?secret=etherpad_name_generator_cirandas&padPrefix="+padPrefix, true);
    		xmlhttp.send();
		} else {
			insert_pad(f.etherpadliteID.value);
		}
		
		// Insert the contents from the input into the document
		function insert_pad(padName) {
			var iframe = "<iframe name='embed_readwrite' src='"+url+padName+"?showControls=true"+options+"&lang=pt&showLineNumbers=true&useMonospaceFont=false'"+size+"></iframe>";
			tinyMCEPopup.editor.execCommand('mceInsertContent', false, iframe);
			tinyMCEPopup.close();
		}
	}
};

tinyMCEPopup.onInit.add(EtherPadLiteDialog.init, EtherPadLiteDialog);

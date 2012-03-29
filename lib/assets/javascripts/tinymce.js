$(document).ready(function() {
   $('textarea.mceAdvance').tinymce({
      script_url : '/assets/tiny_mce/tiny_mce.js',
   editor_selector : "mceAdvance",
   mode : "textareas",
   theme : "advanced",
   browsers : ["msie", "gecko", "safari"],
   convert_fonts_to_spans : true,
   theme_advanced_resizing : true,
   theme_advanced_toolbar_location : "top",
   theme_advanced_statusbar_location : "bottom",
   plugins : "inlinepopups,safari,curblyadvimage,paste,table,advlink,preview,fullscreen",
   extended_valid_elements : "iframe[src|width|height|name|align],applet[code|codebase|archive|name|id|width|height|param]",
   theme_advanced_buttons1 : "bold,italic,underline,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect",
   theme_advanced_buttons2 : "strikethrough,forecolor,backcolor,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,removeformat",
   theme_advanced_buttons3 : "tablecontrols,|,charmap,help,code,preview,fullscreen",
   relative_urls : false,
   language : $("html").attr("lang"),
   site_name : WEBY.current_site
   });

   $('textarea.mceSimple').tinymce({
      script_url : '/assets/tiny_mce/tiny_mce.js',
      editor_selector : "mceSimple",
      mode : "textareas",
      theme : "advanced",
      browsers : ["msie", "gecko", "safari"],
      theme_advanced_resizing : true,
      theme_advanced_toolbar_location : "top",
      theme_advanced_statusbar_location : "bottom",
      plugins : "preview,fullscreen",
      theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,|,removeformat,cleanup,help,|,pasteword,code,preview,fullscreen",
      theme_advanced_buttons2 : "",
      theme_advanced_buttons3 : "",
      relative_urls : false,
      language : $("html").attr("lang")
   });
});

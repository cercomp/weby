//= require tinymce/js/tinymce/tinymce.min
//= require tinymce/js/tinymce/jquery.tinymce.min

$(document).ready(function() {

//    $('textarea.mceAdvance').tinymce({
//       script_url : '/assets/tinymce/js/tinymce/tinymce.min.js',
//       editor_selector : "mceAdvance",
//       mode : "textareas",
//       theme : "advanced",
//       browsers : ["msie", "gecko", "safari"],
//       convert_fonts_to_spans : true,
//       theme_advanced_resizing : true,
//       theme_advanced_toolbar_location : "top",
//       theme_advanced_statusbar_location : "bottom",
//       plugins : "inlinepopups,safari,curblyadvimage,paste,table,advlink,preview,fullscreen",
//       extended_valid_elements : "div[*],span[*],iframe[src|width|height|name|align],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
//       theme_advanced_buttons1 : "bold,italic,underline,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect",
//       theme_advanced_buttons2 : "strikethrough,forecolor,backcolor,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,removeformat",
//       theme_advanced_buttons3 : "tablecontrols,|,charmap,help,code,preview,fullscreen",
//       relative_urls : false,
//       language : $("html").attr("lang")
//   });

     var file_selection = function(id){
       return function(sel){
         if(sel){
           $('#'+id).val(sel[0].original_path.replace(/\?\d+$/, ''));

           tinyMCE.activeEditor.windowManager.windows[0].find('#alt').value(sel[0].description);

           var fieldElm = $('#'+id)[0];
           if("createEvent" in document) {
             var evt = document.createEvent("HTMLEvents");
             evt.initEvent("change", false, true);
             fieldElm.dispatchEvent(evt);
           }else{
            fieldElm.fireEvent("onchange");
           }
         }
       }
     };

     var callback = function(id, value, ftype){
        if(ftype == 'image'){
          WEBY.getRepositoryDialog().open({
            file_types: ["image"],
            selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
            multiple: false,
            onsubmit: file_selection(id)
          });
        }else if(ftype == 'file'){
           WEBY.getTargetDialog().open({
            editable_url: true,
            onsubmit: function(sel, url){
              $('#'+id).val(url);
            }
          });
        }else if(ftype == 'media'){
          //tinyMCE.activeEditor.windowManager.alert('Não implementado!');
          WEBY.getRepositoryDialog().open({
            file_types: ["video"],
            selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
            multiple: false,
            onsubmit: file_selection(id)
          });
        }
     }

     $('textarea.mceAdvance').tinymce({
      plugins: [
         "advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
         "save table contextmenu directionality emoticons template paste textcolor"
      ],
      toolbar: "undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link unlink image | code preview media fullscreen | forecolor backcolor emoticons",
      language: $("html").attr("lang"),
      extended_valid_elements : "div[*],span[*],iframe[src|width|height|name|align],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
      paste_word_valid_elements: "b,strong,i,em,h1,h2",
      menubar: "edit format insert table view",
      browser_spellcheck : true,
      image_advtab: true,
      relative_urls: false,
      toolbar_items_size: 'small',
      file_browser_callback: callback,
      style_formats: [
        {title: 'Bold text', inline: 'b'},
        {title: 'Red text', inline: 'span', styles: {color: '#ff0000'}},
        {title: 'Red header', block: 'h1', styles: {color: '#ff0000'}},
        {title: 'Example 1', inline: 'span', classes: 'example1'},
        {title: 'Example 2', inline: 'span', classes: 'example2'},
        {title: 'Table styles'},
        {title: 'Table row 1', selector: 'tr', classes: 'tablerow1'}
      ]
   });

   // http://www.tinymce.com/wiki.php/Configuration:menu

   $('textarea.mceSimple').tinymce({
      plugins: [
         "advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
         "save table contextmenu directionality emoticons template paste textcolor"
      ],
      paste_word_valid_elements: "b,strong,i,em,h1,h2",
      menubar: "edit format insert table view",
      browser_spellcheck : true,
      toolbar_items_size: 'small',
      file_browser_callback: callback,
      toolbar: "undo redo | bold italic underline strikethrough | forecolor backcolor | alignleft aligncenter alignright alignjustify | link unlink image | code preview fullscreen",
      language : $("html").attr("lang")
   });

//   $('textarea.mceSimple').tinymce({
//      script_url : '/assets/tinymce/js/tinymce/tinymce.min.js',
//      editor_selector : "mceSimple",
//      mode : "textareas",
//      theme : "advanced",
//      browsers : ["msie", "gecko", "safari"],
//      theme_advanced_resizing : true,
//      theme_advanced_toolbar_location : "top",
//      theme_advanced_statusbar_location : "bottom",
//      plugins : "preview,fullscreen",
//      theme_advanced_buttons1 : "bold,italic,underline,|,strikethrough,forecolor,backcolor,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,|,removeformat,cleanup,help,|,pasteword,code,preview,fullscreen",
//      theme_advanced_buttons2 : "",
//      theme_advanced_buttons3 : "",
//      relative_urls : false,
//      language : $("html").attr("lang")
//   });


  

});

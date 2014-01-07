//= require tinymce/js/tinymce/tinymce.min
//= require tinymce/js/tinymce/jquery.tinymce.min

$(document).ready(function() {


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

     var callback = (WEBY.repositoryDialogInstance || WEBY.getTargetDialog)? function(id, value, ftype){
        if(ftype == 'image'){
          if(WEBY.getRepositoryDialog){
            WEBY.getRepositoryDialog().open({
              file_types: ["image"],
              selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
              multiple: false,
              onsubmit: file_selection(id)
            });
          }else{
            //tinyMCE.activeEditor.windowManager.alert('Não implementado!');
          }
        }else if(ftype == 'file'){
          if(WEBY.getTargetDialog){
            WEBY.getTargetDialog().open({
              editable_url: true,
              onsubmit: function(sel, url){
                $('#'+id).val(url);
              }
            });
          }else{
            //tinyMCE.activeEditor.windowManager.alert('Não implementado!');
          }
        }else if(ftype == 'media'){
          if(WEBY.getRepositoryDialog){
            WEBY.getRepositoryDialog().open({
              file_types: ["video"],
              selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
              multiple: false,
              onsubmit: file_selection(id)
            });
          }else{
            //tinyMCE.activeEditor.windowManager.alert('Não implementado!');
          }
        }
     } : null;


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

     $('textarea.mceAdvance').tinymce({
      plugins: [
         "advlist autolink link image lists charmap preview hr anchor",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media",
         "table contextmenu directionality paste textcolor"
      ],
      toolbar1: "undo redo | bold italic underline strikethrough |  alignleft aligncenter alignright alignjustify | styleselect",
      toolbar2: "forecolor backcolor | bullist numlist outdent indent | link unlink image media | removeformat | code preview fullscreen",
      language: $("html").attr("lang"),
      extended_valid_elements : "div[*],span[*],iframe[src|width|height|name|align],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
      paste_word_valid_elements: "b,strong,i,em,h1,h2",
      menubar: "edit format insert table view",
      browser_spellcheck : true,
      image_advtab: true,
      relative_urls: false,
      toolbar_items_size: 'small',
      file_browser_callback: callback
   });

   // http://www.tinymce.com/wiki.php/Configuration:menu

   $('textarea.mceSimple').tinymce({
      plugins: [
         "advlist autolink link image lists charmap preview hr anchor",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media",
         "table contextmenu directionality paste textcolor"
      ],
      paste_word_valid_elements: "b,strong,i,em,h1,h2",
      menubar: "edit format insert table view",
      browser_spellcheck : true,
      relative_urls: false,
      toolbar_items_size: 'small',
      file_browser_callback: callback,
      toolbar: "undo redo | bold italic underline strikethrough | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist | link unlink image | removeformat | code preview fullscreen",
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

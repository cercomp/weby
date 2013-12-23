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


/// TODO reasearch this
/// http://stackoverflow.com/questions/17832495/tinymce-4-x-extend-plugin
/// http://www.whiletrue.it/how-to-implement-a-custom-file-manager-in-tinymce-4/
     $('textarea.mceAdvance').tinymce({
      plugins: [
         "advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
         "save table contextmenu directionality emoticons template paste textcolor"
      ],
      toolbar: "undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link unlink image | code preview media fullscreen | forecolor backcolor emoticons",
      language : $("html").attr("lang"),
      extended_valid_elements : "div[*],span[*],iframe[src|width|height|name|align],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
      paste_word_valid_elements: "b,strong,i,em,h1,h2",
      menubar: "edit format insert table view",
      browser_spellcheck : true,
      image_advtab: true,
      relative_urls: false,
      toolbar_items_size: 'small',
      file_browser_callback: function(id, value, ftype, win){

        if(ftype == 'image'){
          WEBY.getRepositoryDialog().open({
            file_types: ["image"],
            selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
            multiple: false,
            onsubmit: function(sel){
              if(sel){
                $('#'+id).val(sel[0].image_path.replace(/\?\d+$/, ''));
                $('#'+id).change();
              }
            }
          });
        }
        
         //console.log('hkjsdhjfkhdsf '+id+', '+value+', '+ftype);
//         $.ajax({
//              type: "GET",
//              url: "/admin/pages",
//              data: { 'template': "tiny_mce" },
//              dataType: "script",
//              statusCode: {
//                403: function() {
//                  $("#page_list").text("Acesso Negado");
//                }
//              }
//            });
//
//            $.ajax({type: "GET",
//              url: "/admin/repositories",
//              data: { 'template': "tinymce_link" },
//              dataType: "script",
//              statusCode: {
//                403: function() {
//                  $("#repo_list").text("Acesso Negado");
//                }
//              }
//            });
      },
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
      toolbar: "undo redo | bold italic underline strikethrough | forecolor backcolor | alignleft aligncenter alignright alignjustify | link image | code preview fullscreen",
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

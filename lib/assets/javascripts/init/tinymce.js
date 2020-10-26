//= require tinymce

$(document).ready(function() {

  //window.tinymce.suffix = '.min';
  window.tinymce.baseURL = '/assets/tinymce';

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
          include_others: true,
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
          file_types: ["video", "audio"],
          selected: value,//$("input[name='"+uniqlink.data('field-name')+"']"),
          multiple: false,
          onsubmit: file_selection(id)
        });
      }else{
        //tinyMCE.activeEditor.windowManager.alert('Não implementado!');
      }
    }
  } : null;

  var editorSetup = function(ed){
    ed.on('NodeChange', function(e){
      if (e && e.element.nodeName.toLowerCase() == 'img'){
        var width = e.element.width, height = e.element.height;
        //tinyMCE.DOM.setAttribs(e.element, {'width': null, 'height': null});
        // tinyMCE.DOM.setAttribs(e.element, {
        //   'style': 'width:' + width + 'px; height:' + height + 'px;'
        // });
      }
    });
  };

  tinymce.init({
    selector: 'textarea.mceAdvance',
    plugins: [
       "advlist autolink link image lists charmap preview hr anchor", //template
       "searchreplace wordcount visualblocks visualchars code codesample fullscreen insertdatetime media",
       "table contextmenu directionality paste textcolor"
    ],
    toolbar1: "undo redo | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect | fontsizeselect",
    toolbar2: "forecolor backcolor | bullist numlist outdent indent | link unlink anchor image media | removeformat | code codesample preview fullscreen",
    language: $("html").attr("lang").replace('-', '_'),
    extended_valid_elements: "div[*],span[*],iframe[src|width|height|name|align|frameborder|scrolling|id|onload|allowfullscreen],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
    paste_word_valid_elements: "@[style,class],-strong/b,-em/i,-span,-p,-ol,-ul,-li,-table,-tr[*],-td[colspan|rowspan],-th[*],-thead,-tfoot,-tbody,-a[href|name],sub,sup,strike,br,u",
    paste_retain_style_properties: 'all',
    menubar: "edit format insert table view",
    menu: {
      format: {items: 'formats'}
    },
    // templates: [
    //   { title: 'Image flutuante', content: '<div class="pull-left"><img src="default.jpg"/><legend>legenda</legend></div>' },
    //   { title: 'Test template 2', content: 'Test 2' }
    // ],
    style_formats: [
      {title: 'Outros', items: [
        {title: 'Address', format: 'address'}
      ]}
    ],
    style_formats_merge: true,
    browser_spellcheck : true,
    fontsize_formats: "8pt 10pt 12pt 14pt 18pt 24pt 36pt",
    image_advtab: true,
    image_caption: true,
    relative_urls: false,
    entity_encoding : 'raw',
    toolbar_items_size: 'small',
    file_browser_callback: callback,
    setup: editorSetup,
    resize: "both"
  });

  tinymce.init({
    selector: 'textarea.mceSimple',
    plugins: [
       "advlist autolink link image lists charmap preview hr anchor",
       "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media",
       "table contextmenu directionality paste textcolor"
    ],
    menubar: "edit format insert table view",
    style_formats: [
      {title: 'Outros', items: [
        {title: 'Address', format: 'address'}
      ]}
    ],
    style_formats_merge: true,
    browser_spellcheck : true,
    relative_urls: false,
    entity_encoding : 'raw',
    toolbar_items_size: 'small',
    file_browser_callback: callback,
    toolbar: "undo redo | bold italic underline strikethrough | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist | link unlink image | removeformat | code preview fullscreen",
    language : $("html").attr("lang").replace('-', '_'),
    extended_valid_elements: "div[*],span[*],iframe[src|width|height|name|align|frameborder|scrolling|id|onload|allowfullscreen],applet[code|codebase|archive|name|id|width|height|param],video[*],source[*],audio[*]",
    setup: editorSetup,
    resize: "both"
  });

});

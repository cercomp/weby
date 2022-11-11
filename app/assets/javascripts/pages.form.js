//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
  $('#page_text_type').change(function(){
    switchEditor($(this).is(':checked'));
  });
  switchEditor($('#page_text_type').is(':checked'));

  $('#page_text_type').closest('form').submit(submitEditorValues);

  $('.md-editor').each(function(){
    initMarkdownEditor(this)
  });

});

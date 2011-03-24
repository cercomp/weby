// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  var img = new Image
  img.src = '/images/spinner.gif'

  // Mostra spinner em ajax com pagination
  $('.pagination.ajax a').live('click',function (){
    $(this).parent().html('').append(img)
    $.getScript(this.href);
    return false;
  })

  // ManageRoles limpa area do formulário
  $('.role_edit').each(function (link) {
    $(this).bind("ajax:success", function(data, status, xhr) {
      $('#user_'+$(this).attr('user_id')).hide()
    })
  })

  // ManageRoles muda o cursor do ponteiro
  $('.role_edit').each(
    function (link) {
      $(this).bind("ajax:success", function (data, status, xhr) {
        document.body.style.cursor = "default"
        $('#user_'+$(this).attr('user_id')).hide()
      })

      $(this).click(
        function () {
          document.body.style.cursor = "wait"
        }
      )
    }

  )

})

function hide_enroled_option() {
	$('form[id^=\"form_user\"]').each(function (e){ $(this).hide(); })
}

function hide_form(id) {
  $('#user_' + id).show();
  $('#form_user_' + id).hide();

  return false;
}

$().ready(function() {
  $('textarea.mceAdvance').tinymce({
    script_url : '/javascripts/tiny_mce/tiny_mce.js',
    editor_selector : "mceAdvance",
    mode : "textareas",
    theme : "advanced",
    browsers : ["msie", "gecko", "safari"],
    convert_fonts_to_spans : true,
    theme_advanced_resizing : true,
    theme_advanced_toolbar_location : "top",
    theme_advanced_statusbar_location : "bottom",
    plugins : "inlinepopups,safari,curblyadvimage,paste,table",
    theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,fontselect,fontsizeselect",
    theme_advanced_buttons2 : "forecolor,backcolor,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup",
    theme_advanced_buttons3 : "tablecontrols,|,removeformat,charmap,help,code",
    plugin_preview_pageurl : "<%= @site.name.to_s if @site %>"
  });
});
$().ready(function() {
  $('textarea.mceSimple').tinymce({
    script_url : '/javascripts/tiny_mce/tiny_mce.js',
    editor_selector : "mceSimple",
    mode : "textareas",
    theme : "advanced",
    browsers : ["msie", "gecko", "safari"],
    theme_advanced_resizing : true,
    theme_advanced_toolbar_location : "top",
    theme_advanced_statusbar_location : "bottom",
    theme_advanced_buttons1 : "bold,italic,underline,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,|,removeformat,cleanup,help,|,pasteword,code",
    theme_advanced_buttons2 : "",
    theme_advanced_buttons3 : ""
  });
});

SyntaxHighlighter.all();


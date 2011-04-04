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

});

function hide_enroled_option() {
	$('form[id^=\"form_user\"]').each(function (e){ $(this).hide(); })
}

function hide_form(id) {
  $('#user_' + id).show();
  $('#form_user_' + id).hide();

  return false;
}

SyntaxHighlighter.all();

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
      $('#user-'+$(this).attr('user_id')).toggle()
    })
  })

})

function hide_enroled_option() {
	$('form[id^=\"form-user\"]').each(function (e){ $(this).hide(); })
}

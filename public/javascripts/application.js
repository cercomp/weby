$(document).ready(function() {
  $('form[loading=true]')
  .bind('submit', function(){
    LoadingGif($('span#loading'));
  })
  .bind('ajax:complete', function(){
    $('span#loading').hide();
  });
  // Mostra spinner em ajax com pagination
  $('.pages_paginator.ajax a').live('click',function (){
    LoadingGif($(this).parent().parent());
    return false;
  })

  // Mostra spinner em ajax com links de itens por pagina
  $('.per_page_paginator.ajax a').live('click',function (){
    LoadingGif($(this).parent().parent());
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



function LoadingGif(obj){
  this.obj = obj;

  this.img = new Image();
  this.img.src = '/images/spinner.gif';

  this.obj.html(img).show();

  return true;
}

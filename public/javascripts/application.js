$(document).ready(function() {
  var loading = LoadingGif.build();

  $('form[data-remote=true]')
  .bind('submit', function(){
    loading.setLocal($(this).find('span#loading')).show();
  })
.bind('ajax:complete', function(){
  loading.hide();
});
// Mostra spinner em ajax com pagination
$('.pages_paginator a[data-remote=true]').live('click',function (){
  loading.setLocal($(this).parent().parent()).show();
  return false;
})

// Mostra spinner em ajax com links de itens por pagina
$('.per_page_paginator a[data-remote=true]').live('click',function (){
  loading.setLocal($(this).parent().parent()).show();
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

function addToSelect(selectId){
  var new_cat = prompt('nova categoria'), option = new Option(new_cat);
  if(!new_cat) return;
  $(selectId).append(option);
  $(option).attr('selected', true);
}

// Objeto para carregar gif
var LoadingGif = {
  build: function(obj){
    this.obj = obj;
    this.img = new Image();
    this.img.src = '/images/spinner.gif';
    return this;
  },
  setLocal: function(obj){
    this.obj = obj;
    return this;
  },
  show: function(){
    this.obj.html(this.img).show();
    return this;
  },
  hide: function(){
    this.obj.html('').hide();
    return this;
  }
};

function toogle_select_multiple(select){
  if($(select).attr("multiple")){
    $(select).attr("multiple",null);
  }else{
    $(select).attr("multiple","multiple");
  }
}

//= require jquery-ui/widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload
//= require_self
$(function () {

  ///Retirar o div invisivel de template para fora da tag form
  $('.repo-template').insertAfter($('form.new_album_photo'));

  ////Evento do click do botão de excluir o arquivo
  $('#upload-preview').on('click', '.close', function(){
    $(this).parents('.closeable').fadeOut(function(){
      $(this).remove();
      check_uploads();
    })
  });

  $('#current-photos').on('ajax:success', '.close', function(e, data, status, xhr) {
    $(this).parents('.closeable').fadeOut(function(){
      $(this).remove();
    })
  }).on('ajax:error', '.close', function(e, xhr, status, error) {
    console.log(error);

  }).on('ajax:success', '.edit_album_photo', function(e, data, status, xhr) {
    $(this).find('.save-btn').addClass('hide');
  }).on('ajax:error', '.edit_album_photo', function(e, xhr, status, error) {
    console.log(error);
  });

  $('#current-photos').on('keyup', '[name="album_photo[description]"]', function(e){
    var form = $(this).closest('form')
    form.find('.save-btn').removeClass('hide');
    form.find('.status').text(null)
  });

  $('#current-photos').on('click', '.make-cover', function(e){
    $form = $(this).closest('form');
    $.post($form.attr('action'), {make_cover: true, _method: 'patch'}, function(data){
      $('.is-cover').remove()
      $form.replaceWith(data.html);
    }, 'json');
    return false;
  });

  function check_uploads() {
    if ($('#upload-preview .repo-item').length) {
      $('form.new_album_photo .form-actions').removeClass('hide');
    } else {
      $('form.new_album_photo .form-actions').addClass('hide');
    }
  }

  function switch_disable_text(disable){
    var $submit = $('.send-files');
    var $dis_txt = $submit.val();
    $submit.val($submit.data('disable-with')).data('disable-with', $dis_txt).prop('disabled', disable);
  }

  function handleFail(context, errors){
    var $msg = context.find('.status');
    $msg.html(null);
    for(var idx in errors){
       $msg.append('<span class="label label-important">'+errors[idx]+'</span>&nbsp;');
    }
  }

  ////Não envia o submit do form principal, e chama o data.submit de cada arquivo incluido
  $('form.new_album_photo').submit(function(){
    $this = $(this);
    if($this.find('.repo-item').length == 0){
      return false;
    }
    $this.find('.repo-item').each(function(){
      //alert($(this).text());
      $(this).find('.status').html('<img src="'+assetPath('loading-bar.gif')+'"/>').addClass('loading');
      var $data = $(this).data('dataobj');
      //console.log($data);
      $data.formData = {"album_photo[description]" : $(this).find('#album_photo_description').val()};
      $data.submit();
    });
    switch_disable_text(true);
    return false;
  });

  $('form.new_album_photo').fileupload({
    paramName: 'album_photo[image]',
    dataType: 'json',
    url: $('form.new_album_photo').prop('action') + '.json',
    ////Evento de inclusão de arquivo, chamado para cada arquivo selecionado
    add: function (e, data) {
      ////Validação se o arquivo já foi incluído
      var included = false;
      $(".repo-item .file-name").each(function(){
        if($(this).text().trim() == data.files[0].name){
          included = true;
        }
      });
      if(included){
        return;
      }

      var $repoItem = $('.repo-template').clone(true);

      $repoItem.removeClass('repo-template').addClass('repo-item').show();
      $repoItem.find('#album_photo_image').val(data.files[0].name);
      $repoItem.find('.file-name').text(data.files[0].name);
      /////Geração do thumbnail de preview (Se o browser tiver o FileReader)
      if ((/image/i).test(data.files[0].type)) {
        var img = document.createElement('img');
        img.src = URL.createObjectURL(data.files[0]);
        $(img).addClass('preview');
        $repoItem.find('#album_photo_image').hide().after(img);
      }

      $repoItem.appendTo($('#upload-preview'));
      $repoItem.data('dataobj', data);

      data.context = $repoItem;
      check_uploads();
    },
    /////Evento de retorno do processamento, executado para cada envio, executando tanto success ou failure
    always: function (e, data) {
      var $msg = data.context.find('.status');
      $msg.removeClass('loading');
      if($('.status.loading').length == 0){
        switch_disable_text(false);
      }
      check_uploads();
    },
    done: function (e, data) {
       ///No IE, mesmo com erro, ele dispara a função done, vindo do iframe
        if(data.result.errors){
           handleFail(data.context, data.result.errors);
        }else{
          var $repoItem = data.context;
          $repoItem.remove();
          var html = $(data.result.html)
          html.find('.status').html('<span class="label label-success">'+data.result.message+'</span>');
          container = $('<div class="'+ $('.repo-template')[0].className +'"></div>')
          container.removeClass('repo-template').addClass('repo-item')
          $('#current-photos').append(container.html(html));
        }
     },

     fail: function(e, data) {
         console.log(e);
         console.log(data);
        //console.log(data.jqXHR.responseText);
        try{
          var errors = JSON.parse(data.jqXHR.responseText).errors;
        }catch(e){
          var errors = [data.jqXHR.responseText.split(/\r?\n/)[0]]
        }
        handleFail(data.context, errors)
     }
  });

  $('.trigger-form').click(function(){
    $('#current-photos .save-btn:not(.hide)').each(function(){
      $(this).find('[type=submit]').click();
    });
    $('form.edit_album').submit();
    return false;
  });
});

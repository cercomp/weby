//= require jquery-ui/widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload
//= require_self
$(function () {

    ///Retirar o div invisivel de template para fora da tag form
    $('.repo-template').insertAfter($('#create-repository-form'));

    ////Evento do click do botão de excluir o arquivo
    $('#upload-preview').on('click', '.close', function(){
      $(this).parents('.closeable').fadeOut(function(){
        $(this).remove();
      })
    });

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
    $('#create-repository-form').submit(function(){
      if($('.repo-item').length == 0){
        return false;
      }
      $('.repo-item').each(function(){
        //alert($(this).text());
        $(this).find('.status').html('<img src="'+assetPath('loading-bar.gif')+'"/>').addClass('loading');
        var $data = $(this).data('dataobj');
        //console.log($data);
        $data.formData = {"repository[site_id]" : $('#repository_site_id').val(), "repository[description]" : $(this).find('#repository_description').val(), "repository[title]" : $(this).find('#repository_title').val(), "repository[legend]" : $(this).find('#repository_legend').val()};
        $data.submit();
      });
      switch_disable_text(true);
      return false;
    });

    $('#create-repository-form').fileupload({
      paramName: 'repository[archive]',
      dataType: 'json',
      url: $('#create-repository-form').prop('action') + '.json',
      ////Evento de inclusão de arquivo, chamado para cada arquivo selecionado
      add: function (e, data) {

        ////Validação se o arquivo já foi incluído
        var included = false;
        $(".repo-item #repository_archive").each(function(){
          if($(this).val() == data.files[0].name){
            included = true;
          }
        });
        if(included){
          return;
        }

        var $repoItem = $('.repo-template').clone(true);

        $repoItem.removeClass('repo-template').addClass('repo-item').show();
        $repoItem.find('#repository_archive').val(data.files[0].name);
        /////Geração do thumbnail de preview (Se o browser tiver o FileReader)
        if (typeof FileReader !== "undefined" && (/image/i).test(data.files[0].type)) {
            var img = document.createElement('img');
            $(img).css({width: '80px'}).addClass('preview');
            var $div = $('<div/>');
            $div.css({width: '80px', height: '80px', overflow: 'hidden'});
            $div.html(img);

            var reader = new FileReader();
            reader.onload = function(evt){
                img.onload = function(){
                  $repoItem.find('#repository_archive').hide().after($div);
                }
                img.src = evt.target.result;
            };
            reader.readAsDataURL(data.files[0]);
        }

        $repoItem.appendTo($('#upload-preview'));
        $repoItem.data('dataobj', data);

        data.context = $repoItem;
      },
      /////Evento de retorno do processamento, executado para cada envio, executando tanto success ou failure
      always: function (e, data) {
          var $msg = data.context.find('.status');
          $msg.removeClass('loading');
          if($('.status.loading').length == 0){
            switch_disable_text(false);
          }
      },
      done: function (e, data) {
         ///No IE, mesmo com erro, ele dispara a função done, vindo do iframe
          if(data.result.errors){
             handleFail(data.context, data.result.errors);
          }else{
            var $repoItem = data.context;

            $repoItem.find('.status').html('<span class="label label-success">'+data.result.message+'</span>&nbsp;<a href="'+data.result.url+'"><span class="glyphicon glyphicon-eye-open"></span></a>');
            $repoItem.removeClass('repo-item');
            $repoItem.find('#repository_description').prop('disabled', true);
            $repoItem.find('img.preview').wrap($('<a href="'+data.result.repository.archive_url+'" target="_blank"></a>'));
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
});

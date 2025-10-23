//= require jquery-ui/widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload
//= require_self
$(function () {
  console.log('=== ALBUMS.PHOTOS.JS LOADED ===');
  console.log('jQuery version:', $.fn.jquery);
  console.log('FileUpload plugin available:', typeof $.fn.fileupload !== 'undefined');
  console.log('Template element:', $('.repo-template').length);
  console.log('Form element:', $('form.new_album_photo').length);
  console.log('Upload preview container:', $('#upload-preview').length);

  ///Retirar o div invisivel de template para fora da tag form
  $('.repo-template').insertAfter($('form.new_album_photo'));
  console.log('Template moved outside form');

  // Verificar estado inicial das fotos ao carregar a página
  setTimeout(function() {
    check_uploads();
  }, 100);

  ////Evento do click do botão de excluir o arquivo
  $('#upload-preview').on('click', '.close', function(){
    $(this).parents('.closeable').fadeOut(function(){
      $(this).remove();
      check_uploads();
    })
  });

    $('#current-photos').on('ajax:success', '.close', function(e, data, status, xhr) {
    data = JSON.parse(data);
    var $photoElement = $(this).closest('.album-photo');

    if ($photoElement.length > 0) {
      $photoElement.fadeOut(function(){
        $(this).remove();
        check_uploads();
      });
    } else {
      console.error('Não foi possível encontrar o elemento .album-photo para remover');
      location.reload();
    }

    if (data.photo_album.is_cover) {
      $('#album_cover_photo_attributes_id').val(null);
      $('.cover-preview img').attr('href', '');
      $('.cover-preview-cont').addClass('hide');
      $('.cover-preview-cont .file-name').text('');
    }
  }).on('ajax:error', '.close', function(e, xhr, status, error) {
    console.log('Erro ao remover foto:', error);
    console.log('Status:', xhr.status);
    console.log('Response:', xhr.responseText);
    try {
      var errors = JSON.parse(xhr.responseText).errors;
      FlashMsg.error(errors, '#tab-photos');
    } catch(e) {
      FlashMsg.error(['Erro ao remover a foto. Tente novamente.'], '#tab-photos');
    }
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
    $item = $(this).closest('.album-photo');
    $form = $item.find('form');
    $.post($form.attr('action'), {make_cover: true, _method: 'patch'}, function(data){
      $('.is-cover').remove()
      $item.replaceWith(data.html);
      $('#album_cover_photo_attributes_id').val(data.photo_album.id);
      $('.cover-preview img').attr('src', $(data.html).find('img.preview').attr('src'));
      $('.cover-preview-cont').removeClass('hide');
      $('.cover-preview-cont .file-name').text(data.photo_album.image_file_name);
      check_uploads();
    }, 'json');
    return false;
  });

  function check_uploads() {
    const previewCount = $('#upload-preview .repo-item:not(.repo-template):visible').length;
    const maxPhotosPerUpload = 100;

    console.log('=== CHECK_UPLOADS ===');
    console.log('Preview count:', previewCount);
    console.log('Max per upload:', maxPhotosPerUpload);

    // Limpar mensagens de erro antigas
    FlashMsg.clear();

    if (previewCount > 0) {
      console.log('Has items in preview');
      // Verificar se excede o limite de 100 fotos por upload
      if (previewCount > maxPhotosPerUpload) {
        console.log('EXCEEDED LIMIT!');
        FlashMsg.error([`É possível fazer o upload de até ${maxPhotosPerUpload} fotos por vez. Você selecionou ${previewCount} foto(s). Por favor, remova ${previewCount - maxPhotosPerUpload} foto(s).`], '#tab-photos');
        $('form.new_album_photo .form-actions').addClass('hide');
      } else {
        console.log('Within limit, showing submit button');
        // Dentro do limite, mostrar botão de envio
        $('form.new_album_photo .form-actions').removeClass('hide');
      }
    } else {
      console.log('No items in preview, hiding submit button');
      // Sem fotos no preview, esconder botão
      $('form.new_album_photo .form-actions').addClass('hide');
    }

    return previewCount <= maxPhotosPerUpload;
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
      $(this).find('.status').html('<img src="'+assetPath('loading-bar.gif')+'"/>').addClass('loading');
      var $data = $(this).data('dataobj');
      //console.log($data);
      $data.formData = {"album_photo[description]" : $(this).find('#album_photo_description').val()};
      $data.submit();
    });
    switch_disable_text(true);
    FlashMsg.clear();
    return false;
  });

  $('form.new_album_photo').fileupload({
    paramName: 'album_photo[image]',
    dataType: 'json',
    url: $('form.new_album_photo').prop('action') + '.json',
    ////Evento de inclusão de arquivo, chamado para cada arquivo selecionado
    add: function (e, data) {
      console.log('=== ADD EVENT TRIGGERED ===');
      console.log('File name:', data.files[0].name);
      console.log('File type:', data.files[0].type);
      console.log('File size:', data.files[0].size);

      ////Validação se o arquivo já foi incluído
      var included = false;
      $(".repo-item .file-name").each(function(){
        if($(this).text().trim() == data.files[0].name){
          included = true;
        }
      });
      if(included){
        console.log('File already included, skipping:', data.files[0].name);
        return;
      }

      console.log('Cloning template...');
      var $repoItem = $('.repo-template').clone(true);
      console.log('Template cloned:', $repoItem.length);

      $repoItem.removeClass('repo-template').addClass('repo-item').show();
      $repoItem.find('#album_photo_image').val(data.files[0].name);
      $repoItem.find('.file-name').text(data.files[0].name);

      /////Geração do thumbnail de preview (Se o browser tiver o FileReader)
      console.log('Checking FileReader support...');
      console.log('FileReader exists:', typeof FileReader !== "undefined");
      console.log('Is image:', (/image/i).test(data.files[0].type));

      if (typeof FileReader !== "undefined" && (/image/i).test(data.files[0].type)) {
        console.log('Creating image preview...');
        var img = document.createElement('img');
        var reader = new FileReader();

        reader.onload = function(evt){
          console.log('Image loaded successfully');
          img.src = evt.target.result;
        };

        reader.onerror = function(error) {
          console.error('Error reading file:', error);
        };

        reader.readAsDataURL(data.files[0]);
        $(img).addClass('preview');
        $repoItem.find('#album_photo_image').hide().after(img);
      } else {
        console.warn('FileReader not supported or file is not an image');
      }

      console.log('Appending to #upload-preview...');
      $repoItem.appendTo($('#upload-preview'));
      $repoItem.data('dataobj', data);

      data.context = $repoItem;

      console.log('Items in preview:', $('#upload-preview .repo-item:not(.repo-template)').length);
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
          check_uploads();
        }
     },

     fail: function(e, data) {
         console.log('Upload failed:', e);
         console.log('Data:', data);
         console.log('Response status:', data.jqXHR.status);
         console.log('Response text:', data.jqXHR.responseText);

        try{
          var response = JSON.parse(data.jqXHR.responseText);
          var errors = response.errors || ['Erro ao enviar a foto. Tente novamente.'];
        }catch(e){
          console.log('Error parsing response:', e);
          var errors = [data.jqXHR.responseText.split(/\r?\n/)[0] || 'Erro desconhecido ao enviar a foto.']
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

  const input = document.querySelector('#album_photo_image');

  // Listen for files selection
  if (input) {
    console.log('File input found, attaching listener');
    input.addEventListener('change', (e) => {
        console.log('=== FILE INPUT CHANGE EVENT ===');
        console.log('Files selected:', e.target.files.length);
        for(let i = 0; i < e.target.files.length; i++) {
          console.log(`File ${i+1}:`, e.target.files[i].name, e.target.files[i].type);
        }
        // A validação será feita pela função check_uploads() após a adição dos arquivos
    });
  } else {
    console.error('File input #album_photo_image not found!');
  }

  $("input[type='submit']").click(function(){
    // A validação já é feita pela função check_uploads() que controla a visibilidade do botão
    return check_uploads_and_submit();
  });

  function check_uploads_and_submit() {
    const previewCount = $('#upload-preview .repo-item:not(.repo-template):visible').length;
    const maxPhotosPerUpload = 100;

    if (previewCount > maxPhotosPerUpload) {
      FlashMsg.error([`É possível fazer o upload de até ${maxPhotosPerUpload} fotos por vez. Você selecionou ${previewCount} foto(s). Por favor, remova ${previewCount - maxPhotosPerUpload} foto(s).`], '#tab-photos');
      return false;
    }
    return true;
  }
});

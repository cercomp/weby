//= require jquery-ui/widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload
//= require_self
$(function () {
  $('.repo-template').insertAfter($('form.new_album_photo'));
  setTimeout(function() {
    check_uploads();
  }, 100);
  $('#upload-preview').on('click', '.close', function(){
    $(this).parents('.closeable').fadeOut(function(){
      $(this).remove();
      check_uploads();
    })
  });
  $('#current-photos').on('click', '.close', function(e){
    e.preventDefault();
    let $photoElement = $(this).closest('.album-photo');

    if ($photoElement.hasClass('marked-for-deletion')) {
      $photoElement.removeClass('marked-for-deletion');
      $photoElement.find('.deletion-overlay').remove();
    } else {
      $photoElement.addClass('marked-for-deletion');
      $photoElement.append('<div class="deletion-overlay">MARCADA PARA EXCLUSÃO</div>');
    }
  });
  $('#current-photos').on('ajax:success', '.edit_album_photo', function(e, data, status, xhr) {
    $(this).find('.save-btn').addClass('hide');
  }).on('ajax:error', '.edit_album_photo', function(e, xhr, status, error) {
    console.log(error);
  });

  $('#current-photos').on('keyup', '[name="album_photo[description]"]', function(e){
    let form = $(this).closest('form')
    form.find('.save-btn').removeClass('hide');
    form.find('.status').text(null)
  });

  $('#current-photos').on('click', '.make-cover', function(e){
    let $item = $(this).closest('.album-photo');
    let $form = $item.find('form');
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
    const currentPhotosCount = $('#current-photos .repo-item:visible').length;
    const maxPhotosPerUpload = 100;

    FlashMsg.clear();

    updatePhotosCounter(previewCount, currentPhotosCount, maxPhotosPerUpload);

    if (previewCount > 0) {
      console.log('Has items in preview');
      if (previewCount > maxPhotosPerUpload) {
        FlashMsg.error([`É possível fazer o upload de até ${maxPhotosPerUpload} fotos por vez. Você selecionou ${previewCount} foto(s). Por favor, remova ${previewCount - maxPhotosPerUpload} foto(s).`], '#tab-photos');
        $('form.new_album_photo .form-actions').addClass('hide');
      } else {
        console.log('Within limit, showing submit button');
        $('form.new_album_photo .form-actions').removeClass('hide');
      }
    } else {
      console.log('No items in preview, hiding submit button');
      $('form.new_album_photo .form-actions').addClass('hide');
    }

    return previewCount <= maxPhotosPerUpload;
  }

  function updatePhotosCounter(previewCount, currentPhotosCount, maxPhotosPerUpload) {
    let $counter = $('#photos-counter');
    if ($counter.length === 0) {
      $counter = $('<div id="photos-counter" style="margin: 10px 0; padding: 8px; background: #f5f5f5; border-radius: 4px; font-size: 14px;"></div>');
      $('#upload-preview').before($counter);
    }

    if (previewCount > 0) {
      let message = `Fotos selecionadas para upload: ${previewCount}`;
      if (previewCount > maxPhotosPerUpload) {
        message += ` <span style="color: #d9534f; font-weight: bold;">(Limite por upload: ${maxPhotosPerUpload})</span>`;
        $counter.css('background-color', '#f2dede');
      } else {
        message += ` <span style="color: #5cb85c;">(OK - Limite por upload: ${maxPhotosPerUpload})</span>`;
        $counter.css('background-color', '#dff0d8');
      }
      $counter.html(message);
    } else {
      $counter.html('Nenhuma foto selecionada para upload');
      $counter.css('background-color', '#f5f5f5');
    }
  }

  function switch_disable_text(disable){
    let $submit = $('.send-files');
    let $dis_txt = $submit.val();
    $submit.val($submit.data('disable-with')).data('disable-with', $dis_txt).prop('disabled', disable);
  }

  function handleFail(context, errors){
    let $msg = context.find('.status');
    $msg.html(null);
    for(let idx in errors){
       $msg.append('<span class="label label-important">'+errors[idx]+'</span>&nbsp;');
    }
  }
  $('form.new_album_photo').submit(function(){
    let $this = $(this);
    if($this.find('.repo-item').length == 0){
      return false;
    }
    $this.find('.repo-item').each(function(){
      $(this).find('.status').html('<img src="'+assetPath('loading-bar.gif')+'"/>').addClass('loading');
      let $data = $(this).data('dataobj');
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
    add: function (e, data) {
      let $repoItem = $('.repo-template').clone(true);
      $repoItem.removeClass('repo-template').addClass('repo-item').show();
      $repoItem.find('#album_photo_image').val(data.files[0].name);
      $repoItem.find('.file-name').text(data.files[0].name);

      if (typeof FileReader !== "undefined" && (/image/i).test(data.files[0].type)) {
        let img = document.createElement('img');
        let reader = new FileReader();

        reader.onload = function(evt){
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
      $repoItem.appendTo($('#upload-preview'));
      $repoItem.data('dataobj', data);

      data.context = $repoItem;
      check_uploads();
    },
    always: function (e, data) {
      let $msg = data.context.find('.status');
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
          let $repoItem = data.context;
          $repoItem.remove();
          let html = $(data.result.html)
          html.find('.status').html('<span class="label label-success">'+data.result.message+'</span>');
          let container = $('<div class="'+ $('.repo-template')[0].className +'"></div>')
          container.removeClass('repo-template').addClass('repo-item uploaded-in-session')
          container.attr('data-upload-time', Date.now());
          $('#current-photos').append(container.html(html));
          check_uploads();
        }
     },

     fail: function(e, data) {
        try{
          let response = JSON.parse(data.jqXHR.responseText);
          let errors = response.errors || ['Erro ao enviar a foto. Tente novamente.'];
        }catch(e){
          console.log('Error parsing response:', e);
          let errors = [data.jqXHR.responseText.split(/\r?\n/)[0] || 'Erro desconhecido ao enviar a foto.']
        }
        handleFail(data.context, errors)
     }
  });

  $('.trigger-form').click(function(){
    $('#current-photos .save-btn:not(.hide)').each(function(){
      $(this).find('[type=submit]').click();
    });
    const markedForDeletion = $('#current-photos .album-photo.marked-for-deletion');
    if (markedForDeletion.length > 0) {
      let processedCount = 0;
      const totalCount = markedForDeletion.length;

      markedForDeletion.each(function() {
        const $photo = $(this);
        const $deleteBtn = $photo.find('.close');

        if ($deleteBtn.length > 0) {
          $deleteBtn.attr('data-remote', 'true');
          $deleteBtn.attr('data-method', 'delete');
          const photoId = $photo.find('form').attr('id').replace('edit_album_photo_', '');
          $deleteBtn.attr('href', `/admin/albums/${window.location.pathname.split('/')[3]}/album_photos/${photoId}`);
          $photo.one('ajax:success', function(e, data, status, xhr) {
            processedCount++;
            $photo.fadeOut(function() {
              $(this).remove();
            });

            if (processedCount >= totalCount) {
              $('form.edit_album').submit();
            }
          });
          $photo.one('ajax:error', function() {
            processedCount++;

            if (processedCount >= totalCount) {
              $('form.edit_album').submit();
            }
          });
          $deleteBtn.trigger('click');
        } else {
          processedCount++;
          if (processedCount >= totalCount) {
            $('form.edit_album').submit();
          }
        }
      });
    } else {
      $('form.edit_album').submit();
    }

    return false;
  });

  $('.form-actions .btn-default').click(function(e) {
    const recentUploads = $('.uploaded-in-session');
    const markedForDeletion = $('#current-photos .album-photo.marked-for-deletion');

    if (recentUploads.length > 0 || markedForDeletion.length > 0) {
      e.preventDefault();

      let message = '';
      if (recentUploads.length > 0 && markedForDeletion.length > 0) {
        message = `Você tem ${recentUploads.length} foto(s) enviada(s) nesta sessão e ${markedForDeletion.length} foto(s) marcada(s) para exclusão. Deseja cancelar e remover essas mudanças?`;
      } else if (recentUploads.length > 0) {
        message = `Você tem ${recentUploads.length} foto(s) enviada(s) nesta sessão. Deseja cancelar e remover essas fotos?`;
      } else {
        message = `Você tem ${markedForDeletion.length} foto(s) marcada(s) para exclusão. Deseja cancelar e manter essas fotos?`;
      }

      if (confirm(message)) {
        markedForDeletion.each(function() {
          $(this).removeClass('marked-for-deletion');
          $(this).find('.deletion-overlay').remove();
        });
        let processedCount = 0;
        const totalCount = recentUploads.length;
        const redirectUrl = $(this).attr('href');

        if (totalCount === 0) {
          globalThis.location.href = redirectUrl;
          return;
        }

        recentUploads.each(function() {
          const $photo = $(this);
          const $deleteBtn = $photo.find('.close');

          if ($deleteBtn.length > 0) {
            $deleteBtn.attr('data-remote', 'true');
            $deleteBtn.attr('data-method', 'delete');
            const photoId = $photo.find('form').attr('id').replace('edit_album_photo_', '');
            $deleteBtn.attr('href', `/admin/albums/${window.location.pathname.split('/')[3]}/album_photos/${photoId}`);
            $photo.one('ajax:success', function() {
              processedCount++;
              console.log(`Recent upload removed: ${processedCount}/${totalCount}`);

              if (processedCount >= totalCount) {
                console.log('All changes cancelled, redirecting...');
                setTimeout(function() {
                  globalThis.location.href = redirectUrl;
                }, 500);
              }
            });
            $photo.one('ajax:error', function() {
              processedCount++;
              console.log(`Recent upload removal failed: ${processedCount}/${totalCount}`);

              if (processedCount >= totalCount) {
                console.log('Processing finished (with errors), redirecting...');
                setTimeout(function() {
                  globalThis.location.href = redirectUrl;
                }, 500);
              }
            });
            $deleteBtn.trigger('click');
          } else {
            processedCount++;
            if (processedCount >= totalCount) {
              globalThis.location.href = redirectUrl;
            }
          }
        });
      }
    }
  });

  const input = document.querySelector('#album_photo_image');
  if (input) {
    console.log('File input found, attaching listener');
    input.addEventListener('change', (e) => {
        console.log('=== FILE INPUT CHANGE EVENT ===');
        console.log('Files selected:', e.target.files.length);
        for(let i = 0; i < e.target.files.length; i++) {
          console.log(`File ${i+1}:`, e.target.files[i].name, e.target.files[i].type);
        }
    });
  } else {
    console.error('File input #album_photo_image not found!');
  }

  $("input[type='submit']").click(function(){
    return check_uploads_and_submit();
  });

  function check_uploads_and_submit() {
    const previewCount = $('#upload-preview .repo-item:not(.repo-template):visible').length;
    const maxPhotosPerUpload = 100;

    console.log('=== CHECK_UPLOADS_AND_SUBMIT ===');
    console.log('Preview count for submit:', previewCount);
    console.log('Max per upload:', maxPhotosPerUpload);

    if (previewCount > maxPhotosPerUpload) {
      FlashMsg.error([`É possível fazer o upload de até ${maxPhotosPerUpload} fotos por vez. Você selecionou ${previewCount} foto(s). Por favor, remova ${previewCount - maxPhotosPerUpload} foto(s).`], '#tab-photos');
      return false;
    }
    return true;
  }
});

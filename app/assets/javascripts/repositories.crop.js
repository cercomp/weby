//= require cropper

$(document).ready(function () {
  var cropInit = false;
      userValue = false;

  var setValue = function(input, value){
    var input = $("#repository_"+input);
    if (typeof(value) == 'undefined' || value == null){
      value = 0;
    }else if (value % 1 != 0){
      value = Math.round(value);
    }
    input.val(value);
  };

  var getCropper = function(method, args){
    return $('#img-crop').cropper(method, args);
  };

  var initCropper = function(){
    //Após o carregamento da imagem, iniciar o Cropper
    $('#img-crop').on('load', function(){
      $('.real-size').html('<b>('+this.naturalWidth+'x'+this.naturalHeight+')</b>');
      $(this).cropper({
        viewMode: 2,
        movable: false,
        zoomable: false,
        autoCrop: false,
        rotatable: false,
        crop: function (selection) {
          //console.log(selection);
          if (!userValue){
            setValue('x', selection.x);
            setValue('y', selection.y);
            setValue('w', selection.width);
            setValue('h', selection.height);
          }
          userValue = false;
        }
      });
    });
    //Iniciar o carregamento da imagem manualmente
    $('#img-crop').attr('src', $('#img-crop').data('src'));
    cropInit = true;
  };

  //Quando o usuário seta os valores, muda a seleção na imagem
  $('#repository_w,#repository_h').change(function(ev){
    var w = parseInt($('#repository_w').val()),
        h = parseInt($('#repository_h').val());
    var changes = {};

    ////if it's no cropped yet, manually start it
    if (!getCropper('getCropBoxData').width){
      changes['x'] = 0;
      changes['y'] = 0;
      getCropper('crop')
    }
    userValue = true;

    if ($(ev.target).is('#repository_w')){
      changes['width'] = w;
    }else if ($(ev.target).is('#repository_h')){
      changes['height'] = h;
    }
    getCropper('setData', changes);
    var o = getCropper('getData');

    setValue('w', o.width);
    setValue('h', o.height);
  });

  $('.toggle-lock').change(function(){
    var o = getCropper('getData');
    if($(this).is(':checked')){
      $(this).siblings('.glyphicon').removeClass('glyphicon-white');
      if (!getCropper('getCropBoxData').width){
        getCropper('crop')
      }
      getCropper('setAspectRatio', Math.round(o.width)/Math.round(o.height));
    }else{
      $(this).siblings('.glyphicon').addClass('glyphicon-white');
      getCropper('setAspectRatio', 0);
    }
    getCropper('setData', o);
    return false;
  });

  //Simular o efeito de onchange quando pressiona [enter] e impedir que o formulário seja enviado
  $('#repository_w,#repository_h').keydown(function(e){
    if(e.keyCode == 13){
      $(this).change();
      return false;
    }
  });

  //// Init Cropper ////
  if(!cropInit){
    initCropper();
  }

  $('.img-crop').click(function(){
    var $this = $(this);
    var $msg = $('.message-box');

    if (!getCropper('getCropBoxData').width){
      $msg.html('<span class="label label-important">Defina a área de corte</span>&nbsp;');
      return false;
    }

    $this.addClass('disabled').attr('disabled', true);

    var $canvas = getCropper('getCroppedCanvas');
    $canvas.toBlob(function (blob) {
      var fd = new FormData();
      //console.log(blob);
      fd.append('new_version', true);
      fd.append('repository[archive]', blob, $('.filename').data('name'));
      fd.append('repository[title]', $('#repository_title').val());
      fd.append('repository[legend]', $('#repository_legend').val());
      fd.append('repository[description]', $('#repository_description').val());

      $msg.html(null);
      $.ajax($this.data('url'), {
        method: "POST",
        data: fd,
        processData: false,
        contentType: false,
        dataType: "json",
        success: function (data) {
          $this.removeClass('disabled').removeAttr('disabled');

          if (data.repository) {
            //
            location = data.url;
            //$msg.html('<span class="label label-success">'+data.message+'</span>&nbsp;<a href="'+data.url+'"><span class="glyphicon glyphicon-eye-open"></span></a>');
          }else{
            for(var idx in data.errors){
               $msg.append('<span class="label label-important">'+data.errors[idx]+'</span>&nbsp;');
            }
          }
        },
        error: function (xhr, stats, err) {
          $this.removeClass('disabled').removeAttr('disabled');

          var errors = xhr.responseJSON.errors;
          for(var idx in errors){
             $msg.append('<span class="label label-important">'+errors[idx]+'</span>&nbsp;');
          }
        }
      });
    });
    return false;
  });
});
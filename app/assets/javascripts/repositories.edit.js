//= require jquery.Jcrop.min

$(document).ready(function () {
  var jcrop_api,
      jcropInit = false;
      userValue = false;

  var setValue = function(input, data, value){
    if ($("#repository_"+input).data('raw') != data){
      $("#repository_"+input).data('raw', data);
      if (typeof(value) == 'undefined' || value == null){
        value = Math.round(data);
      }else if (value % 1 != 0){
        value = Math.round(value);
      }
      $("#repository_"+input).val(value);
    }
  }

  var initJcrop = function(){
    //Após o carregamento da imagem, iniciar o jCrop
    $('#img-crop').load(function(){
      $('.real-size').html('<b>('+this.naturalWidth+'x'+this.naturalHeight+')</b>');
      $(this).Jcrop({
        boxWidth: this.clientWidth,
        boxHeight: this.clientHeight,
        trueSize: [this.naturalWidth, this.naturalHeight],
        onSelect: function (selection) {
          if (!userValue){
            setValue('x', selection.x);
            setValue('y', selection.y);
            setValue('w', selection.w);
            setValue('h', selection.h);
          }
          userValue = false;
        },
        onRelease: function(){
          $("#repository_x").val(null);
          $("#repository_y").val(null);
          $("#repository_w").val(null);
          $("#repository_h").val(null);
        }
      }, function(){
        jcrop_api = this;
      });
    });
    //Iniciar o carregamento da imagem manualmente
    $('#img-crop').attr('src', $('#img-crop').data('src'));
    jcropInit = true;
  }

  //Quando o usuário seta os valores, muda a seleção na imagem
  $('#repository_w,#repository_h').change(function(){
    $(['x','y','w','h']).each(function(){
      if($('#repository_'+this).val().length == 0)
        $('#repository_'+this).val(0);
    });
    var x = parseInt($('#repository_x').val()),
        y = parseInt($('#repository_y').val()),
        w = parseInt($('#repository_w').val()),
        h = parseInt($('#repository_h').val()),
        aspect = jcrop_api.getOptions().aspectRatio;
    if(aspect != 0){
      if($(this).is('#repository_w')){
        h = w / aspect;
      }else{
        w = h * aspect;
      }
    }
    userValue = true;
    jcrop_api.setSelect([x, y, x+w, y+h]);
    var o = jcrop_api.tellSelect();
    //Se o usuário seta um valor que corta pra fora da imagem,
    //muda o valor do campo para o valor real
    if(Math.abs(w-o.w) > 2){
      w = null;
      if(aspect != 0){
        h = null;
      }
    }
    if(Math.abs(h-o.h) > 2){
      h = null;
      if(aspect != 0){
        w= null;
      }
    }
    setValue('w', o.w, w);
    setValue('h', o.h, h);
  });

  $('.toggle-lock').click(function(){
    if($(this).hasClass('active')){
      $(this).removeClass('active');
      jcrop_api.setOptions({aspectRatio: 0})
    }else{
      $(this).addClass('active');
      var o = jcrop_api.tellSelect();
      jcrop_api.setOptions({aspectRatio: Math.round(o.w)/Math.round(o.h)})
    }
    return false;
  });

  //Simular o efeito de onchange quando pressiona [enter] e impedir que o formulário seja enviado
  $('#repository_w,#repository_h').keydown(function(e){
    if(e.keyCode == 13){
      $(this).change();
      return false;
    }
  });

  //Se o usuário trocar o arquivo, remover o panel de corte da imagem
  $('#repository_archive').change(function(){
    if(jcrop_api)
      jcrop_api.release();
    $('.img-edit').remove();
    /////Geração do thumbnail de preview (Se o browser tiver o FileReader)
    var img = $('.img-edit-preview img');
    img.hide();
    if (typeof FileReader !== "undefined" && (/image/i).test(this.files[0].type)){
      var reader = new FileReader();
      reader.onload = function(evt){
        img[0].src = evt.target.result;
        img.parent('a').attr('href', '#');
        img.parent('a').attr('target', null);
        img.show();
      };
      reader.readAsDataURL(this.files[0]);
    }
  });

  $('.panel-heading').click(function(){
    var $body = $('.img-edit .panel-body');
    $body.slideDown(300, function(){
      if(!jcropInit){
        initJcrop();
      }
    });
    $body.prev('.panel-heading').removeClass('closed').addClass('open');
  });

  $('.img-edit-cancel').click(function(){
    var $body = $('.img-edit .panel-body');
    $body.slideUp(300);
    $body.prev('.panel-heading').removeClass('open').addClass('closed');
    $('.toggle-lock').removeClass('active');
    jcrop_api.setOptions({aspectRatio: 0})
    jcrop_api.release();
    return false;
  });
});
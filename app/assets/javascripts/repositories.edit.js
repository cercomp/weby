//= require jquery.Jcrop.min

$(document).ready(function () {
  var jcrop_api;

  //Após o carregamento da imagem, iniciar o jCrop
  $('#img-crop').load(function(){
    $('.real-width').text(this.naturalWidth);
    $('.real-height').text(this.naturalHeight);
    $(this).Jcrop({
      boxWidth: this.clientWidth,
      boxHeight: this.clientHeight,
      trueSize: [this.naturalWidth, this.naturalHeight],
      onSelect: function (selection) {
        $("#repository_x").val(Math.ceil(selection.x));
        $("#repository_y").val(Math.ceil(selection.y));
        $("#repository_w").val(Math.ceil(selection.w));
        $("#repository_h").val(Math.ceil(selection.h));
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
    $('.img-edit .panel-body').hide();
  });
  //Iniciar o carregamento da imagem manualmente
  $('#img-crop').attr('src', $('#img-crop').data('src'));

  $('.toggle-lock').click(function(){
    if($(this).hasClass('active')){
      $(this).removeClass('active');
      jcrop_api.setOptions({aspectRatio: 0})
    }else{
      $(this).addClass('active');
      var o = jcrop_api.tellSelect();
      jcrop_api.setOptions({aspectRatio: parseInt(o.w)/parseInt(o.h)})
    }
    return false;
  });

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

    jcrop_api.setSelect([x, y, x+w, y+h]);
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
        img.show();
      };
      reader.readAsDataURL(this.files[0]);
    }
  });

  $('.panel-heading').click(function(){
    var $body = $('.img-edit .panel-body');
    $body.slideDown(300);
    $body.prev('.panel-heading').removeClass('closed').addClass('open');
  });

  $('.img-edit-cancel').click(function(){
    var $body = $('.img-edit .panel-body');
    $body.slideUp(300);
    $body.prev('.panel-heading').removeClass('open').addClass('closed');
    jcrop_api.release();
    return false;
  });
});
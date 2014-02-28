//= require jquery.Jcrop.min

$(document).ready(function () {
  var jcroper;

  //Após o carregamento da imagem, iniciar o jCrop
  $('#img-crop').load(function(){
    $('.real-width').text(this.naturalWidth+" px");
    $('.real-height').text(this.naturalHeight+" px");
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
      jcroper = this;
    });
    $('.img-edit .panel-body').hide();
  });
  //Iniciar o carregamento da imagem manualmente
  $('#img-crop').attr('src', $('#img-crop').data('src'));

  //Quando o usuário seta os valores, muda a seleção na imagem
  $('#repository_w,#repository_h').change(function(){
    if($('#repository_x').val().length == 0) $('#repository_x').val(0);
    if($('#repository_y').val().length == 0) $('#repository_y').val(0);
    if($('#repository_w').val().length == 0) $('#repository_w').val(0);
    if($('#repository_h').val().length == 0) $('#repository_h').val(0);
    var x = parseInt($('#repository_x').val()),
        y = parseInt($('#repository_y').val()),
        w = parseInt($('#repository_w').val()),
        h = parseInt($('#repository_h').val());
    if(w < 0){
      $('#repository_w').val(0);
      w = 0;
    }
    if(h < 0){
      $('#repository_h').val(0);
      h = 0;
    }

    jcroper.animateTo([x, y, x+w, y+h]);
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
     jcroper.release();
    $('.img-edit').remove();
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
    jcroper.release();
    return false;
  });
});
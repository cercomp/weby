$(document).ready(function(){
  $('.banner a').click(function(){
    $.post('/count/banner/'+$(this).data('banner-id'));
  });

  $("#banner_list_component_orientation").change(function(){
    if($(this).val() == 'slider')
        $('.slider-form').show();
    else
        $('.slider-form').hide();
  }).change();

  var e = $('.banner_list_component .flexslider');
  if(e.length > 0){
      e.flexslider({
        controlNav: e.data('controls'),
        directionNav: e.data('controls'),
        animation: "slide",
        //controlsContainer: '.flex-container',
        prevText: '&lsaquo;',
        nextText: '&rsaquo;',
        slideshowSpeed: parseInt($(e).data('slideshowspeed'))
      });
  }
  $(document).on('click', '.share-banner', function(){
    var $this = $(this);
    $this.attr('disabled', true);
    $.get($this.data('link'), function(data){
      $('#bannerModal').remove();
      $('body').append(data);
      if(typeof $().modal == 'function') {
        $('#bannerModal').modal();
      } else {
        $('#bannerModal').addClass('open');
      }
      // NOTE - this is not using remote:true anymore because of CORS issues
      // $('#bannerModal .share-action').on('ajax:beforeSend', function(ev, xhr){
      //   xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      // }).on('ajax:success', function(ev, data){
      //   $('#bannerModal .modal-body').text(data.message);
      // }).on('ajax:error', function(ev, xhr){
      //   // TODO check if errr is 413
      //   $('#bannerModal .modal-body').text('Ocorreu um erro, tente novamente');
      // });
      $this.attr('disabled', false);
    });
    return false;
  });

});


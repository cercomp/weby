$(function(){
  $(document).on("click", ".news_list_component .pagination a", function(){
    $comp = $(this).parents('.pagination');
      if($comp.css('position')!='absolute') $comp.css('position', 'relative');
      $comp.prepend($('<div class="loading-cloak"></div>').css({
        position: 'absolute',
        top: 0,
        left: 0,
        height: $comp.outerHeight(),
        width: $comp.outerWidth(),
        textAlign: 'center',
        background: 'rgba(255,255,255,.65) url(/assets/loading.gif) no-repeat center center'
      }));
    });

    $("#news_list_component_show_date").change(function(){
      $('#news_list_component_date_format').prop('disabled', !$(this).is(":checked"));
    }).change();

    $("#news_list_component_show_image").change(function(){
      $('#news_list_component_image_size').prop('disabled', !$(this).is(":checked"));
    }).change();
    
});

//Mudar CSS do contraste
$(document).ready(function() {
  $("a.contrast_normal").click(function(){
    $('head link#contrast_blue').remove();
    $('head link#contrast_black').remove();
    $('head link#contrast_yellow').remove();
  });
  $("a.contrast_blue").click(function(){
    contrast = $('head').append("<link rel='stylesheet' id='contrast_blue' media='screen' href='assets/shared/contrast_blue.css'/>");
    $.cookie("css",$('contrast'), {expires: 30});
    return false;
  });
  $("a.contrast_black").click(function(){
    $('head').append("<link rel='stylesheet' id='contrast_black' media='screen' href='assets/shared/contrast_black.css'/>");
  });
  $("a.contrast_yellow").click(function(){
    $('head').append("<link rel='stylesheet' id='contrast_yellow' media='screen' href='assets/shared/contrast_yellow.css'/>");
  });
});
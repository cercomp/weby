$(document).ready(function(){
  // Contrast check
  if($.cookie("accessibility_css")){ 
    $('head').append($.cookie("accessibility_css"));
  };
  // Contrast reset
  $("a.contrast_normal").click(function(){
    $('head link#contrast_blue').remove();
    $('head link#contrast_black').remove();
    $('head link#contrast_yellow').remove();
    $.cookie("accessibility_css", null, { path: '/' });
  });
  // Contrast events
  $("a.contrast_blue").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_blue' media='screen' href='/assets/shared/contrast_blue.css'/>";
    contrast_define(contrast);
  });
  $("a.contrast_black").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_black' media='screen' href='/assets/shared/contrast_black.css'/>";
    contrast_define(contrast);
  });
  $("a.contrast_yellow").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_yellow' media='screen' href='/assets/shared/contrast_yellow.css'/>";
    contrast_define(contrast);
  });
  // Define contrast
  function contrast_define(contrast){
    $('head').append(contrast);
    $.cookie("accessibility_css", contrast, { path: '/' });
  }
});


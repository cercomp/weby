$(document).ready(function(){
  // Contrast check
  var resetContrast = function(){
    $('head link#contrast_blue').remove();
    $('head link#contrast_black').remove();
    $('head link#contrast_yellow').remove();
    $.cookie("accessibility_css", null, { path: '/' });
  }

  if($.cookie("accessibility_css")){
    $('head').append($.cookie("accessibility_css"));
  };
  // Contrast reset
  $("a.contrast_normal").click(function(){
    resetContrast();
  });
  // Contrast events
  $("a.contrast_blue").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_blue' media='screen' href='" + $(".contrast_blue").data("url") + "'/>";
    contrast_define(contrast);
  });
  $("a.contrast_black").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_black' media='screen' href='" + $(".contrast_black").data("url") + "'/>";
    contrast_define(contrast);
  });
  $("a.contrast_yellow").click(function(){
    var contrast = "<link rel='stylesheet' id='contrast_yellow' media='screen' href='" + $(".contrast_yellow").data("url") + "'/>";
    contrast_define(contrast);
  });
  // Define contrast
  function contrast_define(contrast){
    resetContrast();
    $('head').append(contrast);
    $.cookie("accessibility_css", contrast, { path: '/' });
  }
});


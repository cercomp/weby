//Mudar CSS do contraste
$(document).ready(function() {
    $("a.contrast_normal").click(function(){
        $('head').append("<link rel='stylesheet' media='screen' href=''/>");
    });
    $("a.contrast_blue").click(function(){
        $('head').append("<link rel='stylesheet' media='screen' href='assets/shared/contrast_blue.css'/>");
    });
    $("a.contrast_black").click(function(){
        $('head').append("<link rel='stylesheet' media='screen' href='assets/shared/contrast_black.css'/>");
    });
    $("a.contrast_yellow").click(function(){
        $('head').append("<link rel='stylesheet' media='screen' href='assets/shared/contrast_yellow.css'/>");
    });
});
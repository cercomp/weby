//= require jquery.cookie
//= require_self
var tags = $('*');
var tags_font = tags.not(tags.find(".no_contrast").find("*"));
var font_original = new Array();
var font_change = new Array();

tags_font.ready(function() {
  tags_font.each(function() {
    font_original.push($(this).css('font-size'));
  });
  tags_font.css('font-size', null + 'px');
  for (var i = 0; i < font_original.length; i++) {
    font_change[i] = font_original[i];
  };
})
// Font up
function font_size_change(way) {
  var cont = 0;
  tags_font.each(function() {
    var currentSizeTag = parseInt(font_change[cont].substr(0, font_change[cont].length - 2));

    if (way == 'plus') {
      var newSizeTag = currentSizeTag + 2;
    } else if(way == 'minus') {
      var newSizeTag = currentSizeTag - 2;
    } else { exit; }
    
    font_change[cont] = newSizeTag.toString() + 'px';
    $(this).css('font-size', font_change[cont++]);
  })
}
// Font reset
function font_size_original() {
  var i=0; 
  tags_font.each(function() {
    $(this).css('font-size', font_original[i++]);
  })
  for (var i = 0; i < font_original.length; i++) {
    font_change[i] = font_original[i];
  };
}
// Show
$(document).ready(function() {
  $('#accessibility_button').click(function() {
    var controls = $('.menu_accessibility_extended');

    if (controls.is(":visible")) {
      controls.slideUp(300);
    } else {
      controls.slideDown(300);
    }
    return false;
  });
  $('.close-accessibility').click(function(){
    var controls = $('.menu_accessibility_extended');

    controls.slideUp(300);
    return false;
  });
});


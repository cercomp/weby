//= require jquery.cookie
//= require_self

var rejectTag = 'a';
var tags = $('#wrapper,th,input').not(rejectTag)

tags.ready(function(){
  $.cookie("font_size_original", tags.css('font-size'), {path: '/' });
  tags.css('font-size', null + 'px');
})

function font_size_up(){
  var font = tags.css('font-size');
  var currentSizeTag = parseInt(font.substr(0, font.length - 2));
  var newSizeTag = currentSizeTag + 2;

  if( newSizeTag < ( parseInt($.cookie("font_size_original").substr(0, font.length - 2)) + 10 ) )
    tags.css('font-size', newSizeTag.toString() + 'px');
}

function font_size_down(){
  var font = tags.css('font-size');
  var currentSizeTag = parseInt(font.substr(0, font.length - 2));
  var newSizeTag = currentSizeTag - 1;

  tags.css('font-size', newSizeTag.toString() + 'px');
}

function font_size_original(){ 
  tags.css('font-size', $.cookie("font_size_original"));
  $.cookie("font_size", null, {path: '/'});
}

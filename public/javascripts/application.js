// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  var img = new Image
  img.src = '/images/spinner.gif'

  $('.pagination.ajax a').live('click',function (){
    $(this).parent().html('').append(img)
    $.getScript(this.href);
    return false;
  })
})

/**
 * Script for the pages with component's forms
 */
$(document).ready(function() {
  // var img_cache = {};
  // var img = $('.sel-preview img');
  // var default_image = img.attr('src');

  $('[name=component]').change(function() {
    var selected = $('[name=component]:checked');
  //   var val = selected.val();
    var name = selected.next('.component').find('.widget-name').text();
    var icon = selected.next('.component').find('.widget-icon').html();

    $('.selected-component').removeClass('empty').html(icon+' '+name);

  //   if (img_cache[val]) {
  //     img.attr('src', img_cache[val]);
  //     return;
  //   }

  //   var url = '/assets/components/' + val + '.png';
  //   $.get(url, function() {
  //     img.attr('src', url);
  //     img_cache[val] = url;
  //   }).fail(function(){
  //     img.attr('src', default_image);
  //   });
  });

  var place_holder = "#mini_" + $("input#component_place_holder").val();
  $(place_holder).addClass('clicked');

  /**
  * Mini layout's configurations functions
  */
  // Remove the clicked class of the element
  function clear_mini_layout(){
    $(".clicked").removeClass("clicked");
  }

  //Returns the id without the "mini_" as the value for the input
  function select_position(){
    var id = ""
    $(".clicked").each(function(){ id = this.id});
    $("input[id$=_place_holder]").val(id.slice(5));
  }

  //Controls what happens at the moment the local is selected
  $("[id*=mini_]").click(function(event){
    clear_mini_layout();
    $(event.target).addClass('clicked');
    select_position();
  });
});

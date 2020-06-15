/**
 * Script for the pages with component's forms
 */
$(document).ready(function() {
  var img_cache = {};
  var default_image = $('#component_image').attr('src');

  $('#component_select').change(function() {
    var selected = $('#component_select :selected').val();

    if (img_cache[selected]) {
      $('#component_image').attr('src', img_cache[selected]);
      return;
    }

    var url = '/assets/components/' + selected + '.png';
    $.get(url, function() {
      $('#component_image').attr('src', url);
      img_cache[selected] = url;
    }).fail(function(){
      $('#component_image').attr('src', default_image);
    });
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

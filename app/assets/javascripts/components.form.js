/**
 * Script for the pages with component's forms
 */

/* Initial configuration */
var place_holder = "#mini_"

window.onload = function(){
  place_holder += $("input#component_place_holder").val();
  $(place_holder).addClass('clicked');
};

/**
  * Mini layout's configurations functions
  */
// Remove the clicked class of the element
function clear_mini_layout(){
  $(".clicked").each(function(){
    $(this).removeClass("clicked");
  });
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

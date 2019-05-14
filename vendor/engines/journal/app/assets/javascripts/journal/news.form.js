//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
  $('.input-category').select2({
    width: 'resolve',
    tokenSeparators: [","],
    tags: $('.input-category').data('taglist'),
    createSearchChoice: function(term){
      var eq = false;
      $($('.input-category').select2('val')).each(function(){
        //Case insensitive tagging
        if (this.toUpperCase().replace(/^\s+|\s+$/g,"") == term.toUpperCase().replace(/^\s+|\s+$/g,""))
          eq = true;
      });
      if (eq)
        return false
      else
        return {id: term, text: term.replace(/^\s+|\s+$/g,"")};
    }
  });

  //// Auto-save - check for changes
  var currentValues = {};

  setInterval(function(){
    var sendChanges = false;
    tinyMCE.editors.forEach(function(ed){
      if (currentValues.hasOwnProperty(ed.id)) {
        if (currentValues[ed.id] != ed.getContent()){
          sendChanges = true;
          currentValues[ed.id] = ed.getContent();
        } else {
          //all good, no changes
        }
      } else {
        currentValues[ed.id] = ed.getContent();
      }
    });
    if (sendChanges) {
      $.post($('form').data('drafturl'), currentValues, function(data){
        console.log(data);
      });
    }
  }, 4000);
});

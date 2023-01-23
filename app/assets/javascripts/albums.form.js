//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
  $('.input-category').select2({
    width: 'resolve',
    tokenSeparators: [","],
    multiple: true,
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

  $('.input-tags').select2();

  $('#album_cover_photo_attributes_image').change(function(ev){
    $item = $('.album-photo');
    $item.find('.file-name').text(this.files[0].name);
    if ((/image/i).test(this.files[0].type)) {
      var img = document.createElement('img');
      img.src = URL.createObjectURL(this.files[0]);
      $(img).addClass('preview');
      $item.find('.cover-preview').html(img);
    }
  });

});

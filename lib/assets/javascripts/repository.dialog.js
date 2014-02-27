//= require repositories.index
//= require repository.dialog.window

$(document).ready(function(){

    $('.add-uniq-file .close').click(function(){
        $container = $(this).hide().siblings("div");
        $container.find('input[type=radio]').val(null);
        $container.find('label figure').html(null);
        $container.parents('.add-uniq-file').addClass('without-image');
        return false;
    });


    $('.add-uniq-file').click(function(){
      var uniqlink = $(this);
      WEBY.getRepositoryDialog().open({
        field_name: uniqlink.data('field-name'),
        file_types: uniqlink.data('file-types'),
        selected: $("input[name='"+uniqlink.data('field-name')+"']"),
        multiple: false,
        onsubmit: function(sel){
          if(sel){
            var item = WEBY.Repository.
               UniqTemplate(sel[0], uniqlink.data('field-name'), true).
               replace(/dialog_/gi,'');
            uniqlink.removeClass("without-image");
            $("#"+uniqlink.data('place-name')).html(item).siblings(".close").show();
          }
        }
      });
      return false;
    });

    $('.add-multiple-files .add-button').click(function(){
      var multiplink = $(this);
      WEBY.getRepositoryDialog().open({
        field_name: multiplink.data('field-name'),
        file_types: multiplink.data('file-types'),
        selected: $("input[name='"+multiplink.data('field-name')+"']:checked"),
        multiple: true,
        onsubmit: function(sel, removed){
          var place = $("#"+multiplink.data('place-name'));
          if(sel){
            $(sel).each(function(index, repository) {
              if(place.find('#repository_'+repository.id).length == 0){

                var item = WEBY.Repository.
                ItemTemplate(repository, multiplink.data('field-name'), true, true).
                replace(/dialog_/gi,'');

                place.append(item);
              }
            });
          }
          if(removed){
            $(removed).each(function(){
               place.find('#repository_'+this.id).parent('li').remove();
            });
          }
        }
      });
      return false;
    });

});

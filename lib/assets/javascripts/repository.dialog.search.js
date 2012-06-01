/**
 * Objeto com propriedades de realizar buscas de repositorios(JSON),
 * gerar resultado de busca, apendar resultado onde for desejado.
 */
WEBY.Repository = function (object) {
   for(property in object) {
      this[property] = object[property];
   }

   var getMIMEPath = function (mime) {
      return "/assets/mime_list/" + mime + ".png";
   };

   var getSubTypeOfMIME = function (mime) {
      return mime.split('/').pop();
   };

   try {
      if(this.archive_content_type.match(/image|svg/ig)) {
         this.image_path = this.archive_url;
      } else {
         this.image_path = getMIMEPath(getSubTypeOfMIME(this.archive_content_type));
      }
   } catch(error) {
      console.error('WEBY.Repository: archive_content_type não informado\n' + error.message);
   }
};

WEBY.Repository.ItemTemplate = function (repository, fieldName, multiple, checked) {
   var input_type = multiple ? 'checkbox' : 'radio';
   repository.input_type = input_type;
   repository.fieldName = fieldName;
   repository.checked = checked ? 'checked' : '';
   var templateString = "<li " +
      (repository.checked ? " class='backgrounded'>" : ">") +
      "<label for='dialog_repository_{id}'>" +
      "<figure>" +
      "<img alt='{archive_file_name}' title='{archive_file_name}' src='{image_path}'/>" +
      "<figcaption>{description}</figcaption>" +
      "</figure>" +
      "</label>" +
      "<input name='dialog_{fieldName}' type='{input_type}' id='dialog_repository_{id}'"+
      " value='{id}' " +
      (repository.checked ? " checked='{checked}' />"  : " /> ") +
      "</li>";

   return templateString.supplant(repository);
}

WEBY.Repository.UniqTemplate = function (repository, fieldName, checked) {
   return WEBY.Repository.
      ItemTemplate(repository, fieldName, false, checked).
      replace(/<li[^>]*>|<\/li>/gi,'');
}


/**
 * Objeto para controlar o dialogo da busca de repositorios
 */
WEBY.Repository.Dialog = function(link) {

   var getLinkDataSet = function (link) {
      var dataset = $(link).data();
      for(property in dataset) {
         that[property] = dataset[property];
      }

      that.fileTypes = $.grep(that.fileTypes, function(element) {
         if( element && element !== "false" ) {
            return element;
         } 
      });

      that.fileTypes.toString = function () {
         if (this.length > 1) {
            return '[' + this.join(',') + ']';
         } 
         return this[0];
      }
   };

   var hideUnusedOption = function (option) {
      var regexpOfTypes = new RegExp('(' + that.fileTypes.join('|') + ')', 'gi');
      if ($(option).val() && !$(option).val().match(regexpOfTypes)) {
         $(option).attr("disabled", "disabled").
            removeAttr("selected").hide();
      } else {
         $(option).removeAttr('disabled').show();
      }
   }

   var hideUnusedOptgroups = function () {
      $("#mime_type_").find("optgroup").each(function(index, optgroup){ 
         var hide = true;
         $(optgroup).find('option').each(function(index, option){
            hideUnusedOption(option);
            if(!option.style.cssText.match(/display:\s*none/gi)){
               hide = false;
            }
         });
         if (hide) {
            $(optgroup).attr('disabled', 'disabled').hide();
         } else {
            $(optgroup).removeAttr('disabled').show();
         }
      });
   }

   var setAllOptionValue = function () {
      $("#mime_type_").find('option').
         first().val(that.fileTypes.toString()).
         attr('selected', 'selected');
   }

   this.close = function () {
      //dialogPlace.dialog('close');
      dialogPlace.modal('hide');
   }

   this.openDialog = function (link) {
      this.repositories = {};
      getLinkDataSet(link);
      hideUnusedOptgroups();
      setAllOptionValue();
      includeOnForm.clear();
      //dialogPlace.dialog();
      dialogPlace.addClass('modal fade');
      dialogPlace.modal('show');
   }

   this.isAlreadyIncluded = function (repository) {
      var inputForm = $("#"+this.placeName).
         find('input[value$=' + repository.id + ']:checked');

      return parseInt(inputForm.val()) === repository.id;
   }

   var that = this;
   var dialogPlace = $('#dialog-repository-search');

   var includeOnForm = new WEBY.Repository.Dialog.IncludeOnForm(this);
   var search = new WEBY.Repository.Dialog.Search(this, includeOnForm);

   this.openDialog(link);
}

/**
 * Objeto para tratar a busca de repositórios
 */
WEBY.Repository.Dialog.Search = function (dialog, includeOnForm) {
   var that = this;
   var form = $("#repository-search-form");
   this.getting = false;
a = form; // FIXME q isso?
   form.unbind().bind('submit', function () {
      form.find('#page').val(1);
      includeOnForm.clear();
      appendResult(); 
      paginate();
      return false;
   });

   var search = function () {
      that.getting = true;
      return $.get(form.attr('action'), form.serialize());
   };

   var createItem = function (repository) {
      var checked = dialog.isAlreadyIncluded(repository);

      return WEBY.Repository.
         ItemTemplate(repository, dialog.fieldName, dialog.multiple, checked);
   };

   var paginate = function () {
      var element = includeOnForm.form.find('ul')[0]; 

      var position = function () {
         return (element.scrollTop / (element.scrollHeight - element.clientHeight));
      }

      var isToPaginate = function (position) {
         return ( position >= 0.45 ) &&
            ( includeOnForm.current_page < includeOnForm.num_pages ) &&
            !that.getting;
      }

      var paginateOnScroll = function (){
         if (isToPaginate(position())) {
            form.find("#page").val(function () {
               return parseInt($(this).val()) + 1;
            });
            appendResult();
         }
         return false;
      }
      $(element).unbind().bind('scroll', paginateOnScroll);
   };

   var appendResult = function () {
      var objectGet = search();
      objectGet.success(function(data){
         includeOnForm.current_page = data.current_page;
         includeOnForm.num_pages = data.num_pages;

         $(data.repositories).each(function (index, element) { 
            var repository = new WEBY.Repository(element.repository);
            dialog.repositories[repository.id] = repository;
            includeOnForm.append(createItem(repository)); 
         });

         that.getting = false;
      });
   };
}

/**
 * Objeto para tratar a inclusão dos repositorios selecionados
 * no formulário principal
 */
WEBY.Repository.Dialog.IncludeOnForm = function (dialog) {
   var that = this;
   this.form = $("#repository-include-form"); 
   this.current_page = 0;
   this.num_pages = 0;

   var toggleBackground = function (element) {
      var toggleBackgroundMultiple = function () {
         if ($(element).is(':checked')) {
            $(element).parent('li').addClass('backgrounded');
         } else {
            $(element).parent('li').removeClass('backgrounded');
         }
      };

      var toggleBackgroundUniq = function () {
         var nameEscaped = $(element).
            attr('name').
            escapeForJQuerySelector();

         $("[name=" + nameEscaped + "]:not(:checked)").
            removeClass("backgrounded");

         if ($(element).is(':checked')) {
            $(element).parent('li').addClass('backgrounded');
         }
      };

      if(dialog.multiple) {
         toggleBackgroundMultiple();
      } else {
         toggleBackgroundUniq();
      }
   }

   this.clear = function () {
      this.form.find('ul').html('');
   };

   var removeIncludedRepository = function(element) {
      if (!$(element).is(':checked')) {
         $("#"+dialog.placeName).
            find('input[id$=' + $(element).attr('id').match(/\d+/) + ']').
            parent('li').remove();
      }
   }

   this.append = function (content) {
      that.form.find('ul').append(content); 
      $(that.form).find('input:last').bind('change', function () {
         toggleBackground($(this));
         removeIncludedRepository($(this));
      });
   };

   var include = function () {
      try {
         if(dialog.multiple) {
            that.form.find('input:checked').each(function(index, inputSelected) {
               var repository = dialog.
               repositories[$(inputSelected).attr('id').match(/\d+/)[0]];
            if(!dialog.isAlreadyIncluded(repository)){

               var item = WEBY.Repository.
               ItemTemplate(repository, dialog.fieldName, dialog.multiple, true).
               replace(/dialog_/gi,'');

            $("#"+dialog.placeName).append(item);
            }
            });
         } else {
            var repository = dialog.
               repositories[parseInt(that.form.find('input:checked').attr('id').match(/\d+/)[0])];

            var item = WEBY.Repository.
               UniqTemplate(repository, dialog.fieldName, true).
               replace(/dialog_/gi,'');

            $(".add-uniq-file").removeClass("without-image");
            $("#"+dialog.placeName).html(item);
         }
      } catch (error) {
         console.warn("Nenhum item selecionado.\n" + error.message);
      }

      dialog.close();
      return false;
   };

   $("#repository-include-link").on('click', include);
}


/**
 * Interface chamada para criar o objeto que controla o dialogo.
 * Caso objeto já exista será reutilizado.
 */
function repositorySearch (link) {
   if(WEBY.Repository.repositorySearch) {
      WEBY.Repository.repositorySearch.openDialog(link);
   } else {
      WEBY.Repository.repositorySearch = new WEBY.Repository.Dialog(link); 
   }
}

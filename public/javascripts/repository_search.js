/**
 * Objeto com propriedaddes de realizar buscas JSON,
 * gerar resultado de busca, apendar resultado onde for
 * desejado.
 *
 * Para a paginação(onScroll) funcionar no formulário deve
 * haver um campo hidden(text) com id "page" que será utilizado
 * para manter o estado da página atual.
 *
 * No caso de utilizar o objeto em um dialogo o mainPlace
 * é o próprio dialogo, o searchForm é o formulário de Busca
 * e o resultsPlace é o local onde será 'impresso' o resultado
 * da pesquisa.
 */
//function Search (mainPlace, searchForm, resultsPlace) {
//   var getting = false,
//       currentPage,
//       numPages;
//
//   this.mainPlace = mainPlace;
//   this.searchForm = searchForm;
//   this.resultsPlace = resultsPlace;
//
//   function submitRepositorySearchForm () {
//      clearResults();
//      getAndAppendData();
//      return false;
//   }
//
//   function getAndAppendData () {
//      this.getting = true;
//      $.get(searchForm.attr('action'),
//            searchForm.serialize(),
//            function(data){ appendData(data) });
//      return false;
//   }
//
//   function appendData (data) {
//
//   }
//
//   function paginate(element, current_page, num_pages){
//      var scroll_height = element[0].scrollHeight;
//      var client_height = element[0].clientHeight;
//      var scroll_top    = element[0].scrollTop;
//      var position = (scroll_top / (scroll_height - client_height));
//      if(position >= 0.45 && !getting){
//         if(parseInt(current_page) < parseInt(num_pages)){
//            mainPlace.find("#page").val(function(){
//                  return parseInt($(this).val()) + 1 
//               });
//            getAndAppendData();
//         }
//      }
//   }
//
//   function save () { }
//
//   function clearResults () { }
//
//   function resetSearch () { }
//
//   function toogleBackground () { }
//}

var getting = false;
var current_page;
var num_pages;


function submit_repository_search_form(){
   clearUnselectedResults();
   clear_results();
   get_and_append_data();
   return false;
}

function get_and_append_data(){
   getting = true;
   $.get($("#repository-search-form").attr('action'),
         $("#repository-search-form").serialize(),
         function(data){ append_data(data) });
   return false;
}

function append_data(data){
   num_pages = data.num_pages;
   current_page = data.current_page;

   $(data.repositories).each(function(index, element){
      createItem(element.repository)
      .appendTo($("#repository-search-dialog").
         find('#repositories-search-results'));
   });
   getting = false;
   $("#repositories-search-results").scroll(function(){ 
      paginate($(this), current_page, num_pages);
   });
}

function createItem(repository) {
   var item = $(document.createElement('li'));
       selector = $(document.createElement('input'));
   var label = $(document.createElement('label'));
   var figure = $(document.createElement('figure'));
   var figcaption = $(document.createElement('figcaption'));
   var thumbnail = $(document.createElement('img'));

   figcaption
      .text(repository.description);

   var image = repository.archive_content_type.match(/image|svg/ig) ? repository.archive_url :
      "/images/mime_list/" + repository.archive_content_type.split('/').pop() + ".png";

   thumbnail
      .attr('alt', repository.archive_file_name)
      .attr('src', image);

   figure
      .append(thumbnail)
      .append(figcaption);

   selector
      .attr('name', 'page[repository_ids][]')
      .attr('type', 'checkbox')
      .attr('id', 'result_repository_'+repository.id)
      .attr('checked', $("#files-added").find("#repository_"+repository.id).attr('checked'));

   selector.val(repository.id)

   selector.change(function() {
      toggleBackground($(this));
      if($(this).is(':checked')) {
         save($(this));
      }else{
         remove($(this));
      }
   });

   label
      .attr('for', 'result_repository_'+repository.id)
      .append(figure);

   item
      .append(label)
      .append(selector);

   if(selector.attr('checked')){
      item.addClass("backgrounded");
   }

   return item;
}

function save(element) {
   clearUnselectedResults();
   newElement = $(element).parent().clone();
   newElement.find("input")
      .attr('id', function(){
         return $(this).attr('id').match(/repository.*/) 
      });
   newElement.find("label")
      .attr('for', function(){
         return $(this).attr('for').match(/repository.*/) 
      });
   $("#files-added").append(newElement);
}

function paginate(element, current_page, num_pages){
   var scroll_height = element[0].scrollHeight;
   var client_height = element[0].clientHeight;
   var scroll_top    = element[0].scrollTop;
   var position = (scroll_top / (scroll_height - client_height));
   if(position >= 0.45 && !getting){
      if(parseInt(current_page) < parseInt(num_pages)){
         $("#repository-search-dialog")
            .find("#page").val(function(){
               return parseInt($(this).val()) + 1 
            });
         get_and_append_data();
      }
   }
}

function remove(element) {
   idToRemove = element
      .attr('id').match(/repository.*/)
      $("#files-added").find("#"+idToRemove).parent('li').remove();
}

function clear_results() {
   $("#repository-search-dialog").
      find('#repositories-search-results').
      html('');

   $("#repository-search-dialog").find("#page").val(1);
}

function reset() {
   clear_results();
   $("#repository-search-dialog").find("#search").val("");
}

function toggleBackground(input){
   if(input.is(":checked")){
      input.parent("li").addClass("backgrounded");
   } else {
      input.parent("li").removeClass("backgrounded");
   }
}

function closeRepositorySearch() {
   $("#repository-search-dialog").dialog('close').remove();
}

function clearUnselectedResults() {
   $("#files-added").find('input:not(:checked)').parent('li').remove();
}

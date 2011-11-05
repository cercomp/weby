$(document).ready(function() {
   // Ajax indicator
   $('form[data-remote=true]').bind('submit', function(){
      Loading.show();
   }).ajaxComplete(function(){
      Loading.hide();
   });

   $('a[data-remote=true]').live('click',function (){
      Loading.show();
      return false;
   }).ajaxComplete(function(){
      Loading.hide();
      return false;
   });

   $('form').submit(function(){
      Loading.show();
      $(this).submit();
   })

   /////////////////////////////////////////////////////////////////////////////

   // ManageRoles limpa area do formulário
   $('.role_edit').each(function (link) {
      $(this).bind("ajax:success", function(data, status, xhr) {
         $('#user_'+$(this).attr('user_id')).hide();
      });
   });

   // ManageRoles muda o cursor do ponteiro
   $('.role_edit').each( function (link) {
      $(this).bind("ajax:success", function (data, status, xhr) {
         document.body.style.cursor = "default"
         $('#user_'+$(this).attr('user_id')).hide()
      })

      $(this).click( function () {
         document.body.style.cursor = "wait"
      })
   })
});

function hide_enroled_option() {
   $('form[id^=\"form_user\"]').each(function (e){ $(this).hide(); })
}

function hide_form(id) {
   $('#user_' + id).show();
   $('#form_user_' + id).hide();

   return false;
}

function addToSelect(selectId){
   var new_cat = prompt('nova categoria'), option = new Option(new_cat);
   if(!new_cat) return;
   $(selectId).append(option);
   $(option).attr('selected', true);
}

// Objeto para carregar gif
Loading = {
   place_holder: $(document.createElement('div')), 
   image: new Image(),
   show: function(){
      if($('#ajax-indicator').length <= 0){
         this.place_holder.attr('id', 'ajax-indicator');
         this.place_holder.addClass('ajax-indicator');
         this.image.src = '/images/loading.gif';
         this.place_holder.html(this.image).append(' Loading...');
         this.place_holder.appendTo($('body'));
      }
      this.place_holder.show();
   },
   hide: function(){
      this.place_holder.hide();
   }
}

function toogle_select_multiple(select){
   if($(select).attr("multiple")){
      $(select).attr("multiple",null);
   }else{
      $(select).attr("multiple","multiple");
   }
}

function show_selected_image(object,field_name){
   place = $('#selected-image-of-radio-group-images');

   place.click(function(){
      image = $(this).find('img');
      input = $('input#'+image.attr('id'));
      if(input.prop('checked')){
         input.prop('checked', null);
         image.remove();
         place.before('');
      } 
   });

   $('input[name="'+object+'['+field_name+']"]').change(function(){
      var selected = $(this);
      var image = $('label[for="'+selected.attr('id')+'"] > img').clone();
      image.attr('id',selected.attr('id'));
      place.html(image); 
      selected.prop('checked', true);
   });
}


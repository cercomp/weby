$(document).ready(function() {
   //////////////////////////////////
   set_jquery_ui();
   ////////////////////////////////

   // Ajax indicator
   $('*').ajaxSend(function(){
      Loading.show();
   }).ajaxComplete(function(){
      Loading.hide();
   });

   $('form').submit(function(){
      Loading.show();
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
   });

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
   show: function(isModal){
      if($('#ajax-indicator').length <= 0){
         this.image.src = '/images/loading.gif';
         this.place_holder.html(this.image).append(' Loading...');
         this.place_holder.appendTo($('body'));
         this.place_holder.addClass("ajax-indicator ui-state-highlight");
      }
      this.place_holder.slideDown();
   },
   hide: function(){
      this.place_holder.slideUp();
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

function set_jquery_ui(){
   $(".actions > a, input:submit, button, .button").
      not('.ui-datepicker-trigger').
      button();

   $(".checkbox-button-set > input[type=checkbox]").button();
   $(".radio-button-set > input[type=radio]").button();

   $(".checkbox-button-set, .radio-button-set").buttonset();

   $(".search-button").button({
      icons: { secondary: "ui-icon-search" }
   });

   $(".add-button").button({
      icons: { primary: "ui-icon-plusthick" }
   });

   $(".check-button").button();

   $(".check-button").unbind("click").bind("click", function(){
      console.dir($(this));
      remove_button_icons(".check-button");
      if($(this).is(":checked")){
         add_check_icon($(this));
      }
   });

   $('.multiselect').multiselect().
      addClass("ui-button ui-button-text-only").
      attr('role', 'button');

   $('.datepicker').datepicker({
      dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true,
      showOn: "both",
      buttonImage: "/images/calendar-icon.gif",
      buttonImageOnly: false
   });

   $('.datetimepicker').datetimepicker({
      dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true,
      showOn: "both",
      buttonImage: "/images/calendar-icon.gif",
      buttonImageOnly: false
   });

   $(".tabs").tabs();

   return true;
}

function add_check_icon(element){
   element.button({
      icons: { primary: 'ui-icon-check' }
   });
   return true;
}

function remove_button_icons(elements){
   $(elements).each(function(index, element){
      if(!$(element).is(":checked")){
         $(element).button({
            icons: {}
         });
      }
   });
   return true;
}



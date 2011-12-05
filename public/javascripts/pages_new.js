// Alterna o tipo da página entre evento e notícia
$("input[name=type]").change(function(){
   if($(this).is(":checked")){
      Loading.show(true);
      $.get(this.baseURI, {
         type: $(this).val()
      },
      null,
      'script');
   }else{
      $('#event_fields').hide("fade");
   }
   });

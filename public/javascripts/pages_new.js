$("input[name=type]").change(function(){
   Loading.show(true);
   $.get(this.baseURI, {
      type: $(this).val()
   },
   null,
   'script');
});

WEBY.TargetDialog = function(){

    var settings,
        dialog = this,
        $modal = $('#modal_target_list'),
        $results = $('#target-results');
    
    $modal.on("show", function(){
      var $pagestab = $modal.find(".nav-tabs a[href=#tab-pages]");
      $pagestab.tab("show");
    });

    $results.on("click", ".target-item", function(){
      if(settings.onsubmit){
        var $sel = $(this);
        var url = !settings.editable_url ?
            $sel.data('title') :
            $sel.data('url') ?
                $sel.data('url') :
                $sel.closest("*[data-url-template]").data('url-template').replace("0", $sel.data('id'));
        settings.onsubmit.call($modal, $sel, url);
        dialog.close();
      }
    });

    ////Impedir disparar um evento com nome coincidente
    $modal.find("#target_tabs").on("show", function(ev){
        ev.stopPropagation();
        //TODO Buscar lista de links das extensions
        //ev.target // activated tab
        //ev.relatedTarget // previous tab
    });


    this.clear = function(){
      $('.page-results').remove();
      $('.input-search').val(null);
    }

    this.close = function(){
      $modal.modal('hide');
    }

    this.open = function(options){
      settings = options;
      dialog.clear();
      $modal.modal('show');
    }
};

// Singleton'ish'
WEBY.getTargetDialog = function(){

  if(!this.targetDialogInstance){
    this.targetDialogInstance = new WEBY.TargetDialog();
  }

  return this.targetDialogInstance;
}
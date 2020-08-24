WEBY.TargetDialog = function(){

    var settings,
        dialog = this,
        $modal = $('#modal_target_list'),
        $results = $('#target-results');
    
    $modal.on("shown.bs.modal", function(){
      var $pagestab = $modal.find(".nav-tabs a[href=\"#tab-pages\"]");
      $pagestab.tab("show");
      if($('.page-results').length == 0)
        $(this).find('.btn-search-page').click();
      if($('.repository-results').length == 0)
        $(this).find('.btn-search-repository').click();

    });

    $results.on("click", ".target-item", function(){
      if(settings.onsubmit){
        var $sel = $(this);
        var url = !settings.editable_url ?
            $sel.data('title') :
            $sel.data('url') 
        settings.onsubmit.call($modal, $sel, url);
        dialog.close();
      }
    });

    this.clear = function(){
      $('.page-results, .repository-results').remove();
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

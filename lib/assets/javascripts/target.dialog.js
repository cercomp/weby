WEBY.TargetDialog = {

    init: function(){
        var $modal = $('#modal_target_list');
        this.modal = $modal;

        $modal.on("show", function(){
            var $pagestab = $modal.find(".nav-tabs a[href=#tab-pages]");
            $.get($pagestab.data('link'),{'template' : 'list_popup'}, function(data){
              $pages = $modal.find("#tab-pages").html(data);
            });
            $pagestab.tab("show");
        });

        $(document).on("click", "#modal_target_list tr.target-item", function(){
            WEBY.TargetDialog.selected($(this));
        });

        $('input[data-target-content]').change(function(){
           $('input[data-target-id][data-prefix='+$(this).data('prefix')+']').val(null);
           $('input[data-target-type][data-prefix='+$(this).data('prefix')+']').val(null);
        });

        ////Impedir disparar um evento com nome coincidente
        $modal.find("#target_tabs").on("show", function(ev){
            ev.stopPropagation();
            //TODO Buscar lista de links das extensions
            //ev.target // activated tab
            //ev.relatedTarget // previous tab
        });
    },

    selected: function($line){
        $('#'+this.input_filter+' input[data-target-id]').val($line.data('id'));
        $('#'+this.input_filter+' input[data-target-type]').val($line.data('type'));
        $cont = $('#'+this.input_filter+' input[data-target-content]');
        $cont.val( $cont.prop('disabled') ? 
            $line.data('title') :
            $line.data('url') ?
                $line.data('url') :
                $line.closest("*[data-url-template]").data('url-template').replace("0", $line.data('id')) );
        this.modal.modal('hide');
    },

    show: function(input_field){
        this.input_filter = input_field
        this.modal.modal('show');
    }
};

$(function(){
    WEBY.TargetDialog.init();
});


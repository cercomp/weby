//TODO criar uma classe para o div que tampa a tabela para que o usuário possa modificar
$(function(){
    $(document).on("click", ".news_list_component .pagination a", function(){
        $comp = $(this).parents('.news_list_component');
        $comp.css('position', 'relative');
        $tbl = $comp.find('table.list');
        $comp.prepend('<div class="loading-cloak" style="position: absolute; top: 0; left: 0; height: '+($tbl.height()+1)+'px; width: '+($tbl.width()+1)+'px; text-align: center; background: rgba(0,0,0,.1) url(/assets/loading.gif) no-repeat center center;"></div>');
    });
});

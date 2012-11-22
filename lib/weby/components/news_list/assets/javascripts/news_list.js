$(function(){
    $(document).on("click", ".news_list_component .pagination a", function(){
        $(this).parents('.news_list_component').find('table.list').remove();
        $(this).parents('.news_list_component').prepend('<img src="/assets/spinner.gif"/>');
    });
});

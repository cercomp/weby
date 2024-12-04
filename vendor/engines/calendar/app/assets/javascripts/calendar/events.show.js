// vendor/engines/calendar/app/assets/javascripts/calendar/events.show.js
$(document).ready(function () {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery não está carregado!');
        return;
    }
    if (typeof $.fn.modal === 'undefined') {
        console.error('Bootstrap modal não está carregado!');
        return;
    }

    console.log('Libraries loaded correctly');
});
$(document).ready(function () {
    // Debug logs
    console.log('Events show JS loaded');

    // Modal trigger handler
    $('[data-toggle="modal"][data-target="#myModalEvent"]').on('click', function (e) {
        e.preventDefault();
        console.log('Share button clicked');
        $('#myModalEvent').modal('show');
    });

    // Modal events for debugging
    $('#myModalEvent').on('show.bs.modal', function () {
        console.log('Modal is showing');
    }).on('shown.bs.modal', function () {
        console.log('Modal is shown');
    }).on('hide.bs.modal', function () {
        console.log('Modal is hiding');
    });
});
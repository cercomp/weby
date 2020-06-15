$(document).ready(function() {
  var canvas = $("#tagCanvas");
  if (canvas.tagcanvas) {
    var opts = {
      textColour: canvas.data('color'),
      outlineMethod: canvas.data('hover-type'),
      weight: true,
      weightMode: "size",
      weightFrom: "data-weight",
      outlineColour: canvas.data('hover-color'),
      textHeight: 15,
      reverse: true,
      depth: 0.8,
      maxSpeed: canvas.data('speed'),
      shape: canvas.data('cloud-type')
    }
    if (canvas.data('lock_x')) {
      opts.lock = 'x';
    }
    canvas.tagcanvas(opts, 'tags');
  } else {
    canvas.hide();
  }
});

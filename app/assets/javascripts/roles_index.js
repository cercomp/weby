function checkAll(id, checked) {
  var els = $(id).find('input[type=checkbox]');
  for (var i = 0; i < els.length; i++) {
    if (els[i].disabled==false) {
      els[i].checked = checked;
    }
  }
}
function toggleCheckboxesBySelector(selector) {
  boxes = $(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) {
    if (boxes[i].checked == false) {
      all_checked = false;
    }
  }
  for (i = 0; i < boxes.length; i++) {
    boxes[i].checked = !all_checked;
  }
}

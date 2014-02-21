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

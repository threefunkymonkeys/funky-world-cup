body = $("body")

body.on('click', '#edit-prize-btn', function(event) {
  event.preventDefault();
  event.stopPropagation();
  
  $("#prize-form").submit();
});

body.on('click', '#new-prize-btn', function(event) {
  event.preventDefault();
  event.stopPropagation();
  var _this = $(this),
      input = _this.parent().find("#new-prize"),
      prize = input.val(),
      list = $("#prizes-list"),
      new_prize;
  
  _this.parent().removeClass('has-error');

  if(prize.trim() == "") {
    _this.parent().addClass('has-error');
    return;
  }
  
  $("#no-prize").hide();
  $("#edit-prize-btn").removeClass("hide")
  new_prize = $("<li>").addClass("list-group-item")
                       .text(prize.trim())
                       .append($("<input type='hidden' name='prizes[]'>").val(prize.trim()))
                       .append($("<button type='button' class='close pull-right'>").text("×"))
                       .append(
                         $("<ul class='pager pull-right'>").append($("<li><a href='#' class='up'>up</a></li>"))
                                                           .append($("<li class='disabled'><a href='#' class='down'>down</a></li>"))
                       );
  list.append(new_prize);

  input.val("");
  
  window.update_prizes_list();
});


body.on('click', '#prizes-list .close', function(event) {
  event.preventDefault();
  event.stopPropagation();
  var _this = $(this);
  _this.parents(".list-group-item").remove();
  
  window.update_prizes_list();
});

body.on('click', '#prizes-list .up', function(event) {
  event.preventDefault();
  var _this = $(this);
  if(_this.parents('li').hasClass('disabled')) {
    return;
  }

  var this_parent = _this.parents(".list-group-item");
  var prev = this_parent.prev();
  this_parent.insertBefore(prev);
  
  window.update_prizes_list();
});

body.on('click', '#prizes-list .down', function(event) {
  event.preventDefault();
  var _this = $(this);
  if(_this.parents('li').hasClass('disabled')) {
    return;
  }

  var this_parent = _this.parents(".list-group-item");
  var next = this_parent.next();
  this_parent.insertAfter(next);

  window.update_prizes_list();
});

window.update_prizes_list = function() {
  var list = $("#prizes-list");
  list.find('.pager li').removeClass('disabled');
  var items = list.find('.list-group-item')
  $(items[0]).find('.pager .up').parent().addClass('disabled');
  $(items[items.length - 1]).find('.pager .down').parent().addClass('disabled');
}

// Group Delete Modal

body.on("click", "#delete-group", function(event) {
  event.preventDefault();
  event.stopPropagation();

  $("#modal-delete").show();
});

// General Popup close bind

body.on("click", ".modal .modal-close", function(event) {
  event.preventDefault();
  event.stopPropagation();

  $("#modal-delete").hide();
});

// Group link
$("#sharecode").select().on('click', function(event) {
  event.preventDefault();
  event.stopPropagation();
  $(this).select();
});

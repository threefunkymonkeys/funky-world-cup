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
                       .append($("<button type='button' class='close pull-right'>").html("&times;"))
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

  $(this).parents(".modal").hide();
});

// Group link
$("#sharecode").select().on('click', function(event) {
  event.preventDefault();
  event.stopPropagation();
  $(this).select();
});

//Group kick participant

body.on("click", ".kick-participant", function(event) {
  event.preventDefault();
  event.stopPropagation();
  var _this = $(this),
      name = _this.attr('data-name'),
      id = _this.attr('data-id'),
      group_id = _this.parents(".panel-body").attr('data-group');

  modal = $("#modal-kick");
  modal.find('form').attr('action', "/groups/" + group_id + "/kick/" + id);
  modal.find('#popup-participant-name').text(name);

  modal.modal('show');
});

//Group leave

body.on("click", "#leave-group", function(event) {
  event.preventDefault();
  event.stopPropagation();
  $("#modal-leave").modal('show');
});

// Predictions modal

body.on('click', ".btn-predict", function(event) {
  event.preventDefault();
  event.stopPropagation();
  var _this = $(this),
      host_name  = _this.attr("data-host"),
      host_flag  = _this.attr("data-host-flag"),
      rival_name = _this.attr("data-rival"),
      rival_flag = _this.attr("data-rival-flag"),
      match_id   = _this.attr("data-match")
      penalties  = _this.attr("data-penalties") === "true";

  var modal = $("#modal-predict");
  modal.find(".alert-penalties").hide();

  modal.find("#match-id").val(match_id);
  modal.find("input[type=\"text\"]").val(0);

  var host_td = modal.find("td.predict-host");
  host_td.html($("<img class='flag'>").attr("src", "/img/flags/" + host_flag));

  var rival_td = modal.find("td.predict-rival");
  rival_td.html($("<img class='flag'>").attr("src", "/img/flags/" + rival_flag));

  modal.on('click', "input[type=\"text\"]", function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    $(this).select();
  });

  if(penalties) {
    modal.find(".modal-penalties").show();
    modal.find(".alert-penalties").show();
  }

  modal.modal('show');
});

body.on('click', "#modal-predict #submit-prediction", function(event) {
  event.preventDefault();
  event.stopPropagation();

  $("#prediction-form").submit();
});

body.on('change', "#teams-filter", function(event){
  window.location = "/teams/" + event.target.value;
});

body.on('click', "#open-share-modal", function(event) {
  event.preventDefault();
  event.stopPropagation();

  $("#modal-share").modal('show');
});

// Anchor highlight

var anchor = window.location.hash

if(anchor != "") {
  $(anchor).addClass("fwc-highlight");
}

// Matches time

Vue.component("td-match-time", {
  props: ["date"],
  data: function() {
    return {};
  },
  computed: {
    localTime: function() {
      var local = new Date(this.date);

      return local.getHours() + ":" + (local.getMinutes() < 10 ? '0' : '') + local.getMinutes();
    },
    localTimezone: function () {
      var offset =  new Date().getTimezoneOffset() / 60;
      var timezone = "GMT";

      if (offset > 0) {
        timezone += "&minus;" + offset;
      } else {
        timezone += "+" + Match.abc(offset);
      }

      return timezone;
    },
  },

  template: "<td class='text-center'><span class='time text-success'>{{ localTime }}<br><span v-html='localTimezone'></span></span></td>"
});

var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL"];

Vue.component("span-match-date", {
  props: ["date"],
  data: function() {
    return {};
  },
  computed: {
    localDate: function() {
      var local = new Date(this.date);

      return [local.getDate(), months[local.getMonth()]].join(" ")
    }
  },

  template: "<span>{{ localDate }}</span>"
});


Vue.component("result-holder", {
  template: "<div class='result-holder'><strong class='status' :class='styleObject'>{{ isFinal() ? final : progress }}<br></strong><div class='result'><span class='host-result-mobile'>{{ liveHostScore }}</span> - <span class='rival-result-mobile'>{{ liveRivalScore }}</span></div></div>",

  props: ["progress", "final", "status", "matchId", "hostScore", "rivalScore"],
  data: function() {
    return {
      intervalId: null,
      liveHostScore: 0,
      liveRivalScore: 0
    }
  },
  computed: {
    statusText: function() {
      let text = isFinal() ? this.final : this.partial

      return text;
    },
    styleObject: function(){
      return {
        'text-success': this.status != 'final',
        'text-danger': this.status == 'final'
      }
    }
  },
  methods: {
    isFinal: function() {
      return this.status == 'final';
    },
    updateResult: function(){
      if (this.isFinal()){
        window.clearInterval(this.intervalId);
        return;
      }
      const request = {
        url: '/matches/' + this.matchId + '/result',
        method: 'GET',
        headers: {
          'Content-type': 'application/json',
        },
        transformResponse: (data, headers) => {
          try {
            return JSON.parse(data)
          } catch (e) {
            return []
          }
        }
      };

      axios.request(request).then((response) => {
        this.liveHostScore = response.data.host_score;
        this.liveRivalScore = response.data.rival_score;
        this.status = response.data.status;
      }).catch((error) => {
        console.log("Error updating result");
      })
    }
  },

  created: function() {
    if (this.hostScore)
      this.liveHostScore = this.hostScore;

    if (this.rivalScore)
      this.liveRivalScore = this.rivalScore;

    this.intervalId = window.setInterval(this.updateResult, 15000);
  }

});

new Vue({ el: "#matches-root" });

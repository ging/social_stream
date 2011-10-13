closeAllSettings = function() {
  $(".settings_content").hide("slow");
  $(".settings_briefing").show("slow");
}
showSettings = function(name) {
  closeAllSettings();
  if($("#" + name + "_content").css("display") == "none") {
    $("#" + name + "_briefing").hide("slow");
    $("#" + name + "_content").show("slow");
  } else {
    $("#" + name + "_briefing").show("slow");
    $("#" + name + "_content").hide("slow");
  }
}
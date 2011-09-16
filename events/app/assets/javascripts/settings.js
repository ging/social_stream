// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
var contact_manage_open = false;
closeSettings = function() {
    $("#contact_settings_content").hide("slow");
    $("#contact_settings_briefing").show("slow");
    contact_manage_open = false;
}
showContactSettings = function() {
    if (contact_manage_open) {
        $("#contact_settings_content").hide("slow");
        $("#contact_settings_briefing").show("slow");
        contact_manage_open = false;
    } else {
        closeAllSettings();
        $("#contact_settings_content").show("slow");
        $("#contact_settings_briefing").hide("slow");
        contact_manage_open = true;
    }
}

var notifications_open = false;
var api_key_open = false;

closeAllSettings = function() {
    $("#notifications_settings_content").hide("slow");
    $("#notifications_settings_briefing").show("slow");
    notifications_open = false;
    $("#api_key_settings_content").hide("slow");
    $("#api_key_settings_briefing").show("slow");
    api_key_open = false;
}
showNotificationsSettings = function() {
    if (notifications_open) {
        $("#notifications_settings_content").hide("slow");
        $("#notifications_settings_briefing").show("slow");
        notifications_open = false;
    } else {
        closeAllSettings();
        $("#notifications_settings_content").show("slow");
        $("#notifications_settings_briefing").hide("slow");
        notifications_open = true;
    }
}
showApiKeySettings = function() {
    if (api_key_open) {
        $("#api_key_settings_content").hide("slow");
        $("#api_key_settings_briefing").show("slow");
        api_key_open = false;
    } else {
        closeAllSettings();
        $("#api_key_settings_content").show("slow");
        $("#api_key_settings_briefing").hide("slow");
        api_key_open = true;
    }
}

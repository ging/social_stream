////////////////////
//Store password with session storage
////////////////////

$(document).ready(function () {
		$('.storePass').bind('click', function () {
         storePassword();
    });
});


function storePassword() {
    if (window.sessionStorage) {
			if (($("#user_password").length==1)&&($("#user_password").val()!="")){
        sessionStorage.setItem("ss_user_pass", $('#user_password').val());
      } else if (($("#password").length==1)&&($("#password").val()!="")){
				sessionStorage.setItem("ss_user_pass", $('#password').val());
			}
    }
}
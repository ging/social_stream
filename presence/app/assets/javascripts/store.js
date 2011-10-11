////////////////////
//Store password with session storage
////////////////////

function log(msg) {
    console.log(msg)
}

$(document).ready(function () {

		$('#sign_in_header').bind('click', function () {
      	 storePassword();
    });
		
		$('.storePass').bind('click', function () {
         storePassword();
    });
});


function storePassword() {
    if (window.sessionStorage) {
			if (($("#user_password").length==1)&&($("#user_password").val()!="")){
        sessionStorage.setItem("ss_user_pass", $('#user_password').val());
      }
    }
}
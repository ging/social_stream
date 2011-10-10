//= require jquery.validate
//= require jquery.fcbkcomplete

$(function() {
  jQuery.validator.addMethod("phone", function(value, element){
      return this.optional(element) || /^((\((\+?)\d+\))?|(\+\d+)?)[ ]*-?(\d+[ ]*\-?[ ]*\d*)+$/.test(value);
    }, " Please enter a valid telephone number");
	$(".edit_profile").validate({errorClass: "validation_error"});
});

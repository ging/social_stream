$(document).ready( function() {
  //Full Caption Sliding (Hidden to Visible)
  $('.boxgrid.captionfull').hover( function() {
    $(".cover", this).stop().animate({top:'61px'},{queue:false,duration:160});
  }, function() {
    $(".cover", this).stop().animate({top:'104px'},{queue:false,duration:160});
  });
});
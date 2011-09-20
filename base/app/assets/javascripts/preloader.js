$.preloadImages = function() {
  for (var i = 0; i<arguments.length; i++) {
    img = new Image();
    img.src = arguments[i];
  }
}
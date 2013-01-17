// Useful functions for Place form
  var keyupTimer;
  function keyUpEvent(){
    clearTimeout(keyupTimer);
    keyupTimer = setTimeout(searchPlace, 1000);
  }

  function searchPlace(){
    //TO-DO
  }

  function parseCountry(address) {
    var lastComma = address.lastIndexOf(", ");
    if (lastComma == -1) {
      lastComma = -2;
    }
    return address.substring(lastComma + 2);
  }

  function parseStreetNNumber(address, locality, postalcode) {
    var city = address.lastIndexOf(locality);
    var postal = address.lastIndexOf(postalcode);
    var cutindex;
    if (postal == -1 || city < postal) {
      cutindex = city;
    } else {
      cutindex = postal;
    }
    return address.substring(0, cutindex - 2);
  }



// Autocomplete de Places API
function initialize() {
  var map = Gmaps.map.serviceObject;

  var input = document.getElementById('place_title');
  var autocomplete = new google.maps.places.Autocomplete(input);

  autocomplete.bindTo('bounds', map);

  var infowindow = new google.maps.InfoWindow();
  var marker = new google.maps.Marker({
    map: map
  });

  google.maps.event.addListener(autocomplete, 'place_changed', function() {
    $(".street").val("");
    $(".postalcode").val("");
    $(".locality").val("");
    $(".region").val("");
    $(".country").val("");
    $(".place_phone_number").val("");
    $(".place_url").val("");

    infowindow.close();
    var place = autocomplete.getPlace();
    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(17);  // Why 17? Because it looks good.
    }

    if (place.name) {
      $(".place_name").blur();
      $(".place_name").val(place.name);
    }

    var locality;
    var postalcode;
    if (place.address_components) {
      for (var i = 0; i < place.address_components.length; i++ ) {
        var component = place.address_components[i].types[0];
        var component_value = place.address_components[i].long_name;
        if (component == "postal_code") {
          postalcode = component_value;
          $(".postalcode").val(component_value);
        } else if (component == "locality") {
          locality = component_value;
          $(".locality").val(component_value);
        } else if (component == "administrative_area_level_1" || component == "administrative_area_level_2") {
          $(".region").val(component_value);
        //} else if (component == "country") {
        //  $(".country").val(component_value);
        }
      }
    }

    if (place.formatted_address) {
      $(".street").val(parseStreetNNumber(place.formatted_address, locality, postalcode));
      $(".country").val(parseCountry(place.formatted_address));
    }

    if (place.formatted_phone_number) {
     $(".place_phone_number").val(place.formatted_phone_number);
    }

    if (place.website) {
     $(".place_url").val(place.website);
    }

    $("#place_latitude").val(place.geometry.location.lat());
    $("#place_longitude").val(place.geometry.location.lng());

    var image = new google.maps.MarkerImage(
        place.icon,
        new google.maps.Size(71, 71),
        new google.maps.Point(0, 0),
        new google.maps.Point(17, 34),
        new google.maps.Size(35, 35));
    marker.setIcon(image);
    marker.setPosition(place.geometry.location);

    infowindow.setContent('<div><div class=\"place_window_title\">' + place.name + '</div>' + place.formatted_address + '</div>');
    infowindow.open(map, marker);
  });

}
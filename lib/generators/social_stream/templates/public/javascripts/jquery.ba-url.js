/*!
 * URL Utils - v1.11 - 9/10/2009
 * http://benalman.com/
 * 
 * Copyright (c) 2009 "Cowboy" Ben Alman
 * Licensed under the MIT license
 * http://benalman.com/about/license/
 */

// Script: URL Utils
//
// Version: 1.11, Date: 9/10/2009
// 
// Tested with jQuery 1.3.2 in Internet Explorer 6-8, Firefox 3-3.6a,
// Safari 3-4, Chrome, Opera 9.6.
// 
// Home       - http://benalman.com/projects/jquery-url-utils-plugin/
// Source     - http://benalman.com/code/javascript/jquery/jquery.ba-url.js
// (Minified) - http://benalman.com/code/javascript/jquery/jquery.ba-url.min.js (3.9kb)
// Unit Tests - http://benalman.com/code/unittest/url.html
// 
// About: License
// 
// Copyright (c) 2009 "Cowboy" Ben Alman
// 
// Licensed under the MIT license
// 
// http://benalman.com/about/license/
// 
// About: Revision History
// 
// 1.11 - Minor bugfix for Firefox 3.0+
// 1.1 - Added support for onhashchange event
// 1.0 - Initial release

(function($) {
  '$:nomunge'; // Used by YUI compressor.
  
  var url_regexp,
    tag_attributes = {},
    
    // A few constants.
    undefined,
    window = this,
    TRUE = true,
    FALSE = false,
    has_onhashchange = 'onhashchange' in window,
    
    // Some convenient shortcuts.
    aps = Array.prototype.slice,
    loc = document.location,
    
    // Internal plugin method references.
    p_urlTagAttrList,
    p_urlInternalHost,
    p_urlInternalRegExp,
    p_isUrlInternal,
    p_isUrlExternal,
    p_urlFilter,
    p_urlFilterSelector,
    p_setFragment,
    
    // Reused internal strings.
    str_urlInternal     = 'urlInternal',
    str_urlExternal     = 'urlExternal',
    str_queryString     = 'queryString',
    str_fragment        = 'fragment',
    str_update          = 'update',
    str_passQueryString = 'passQueryString',
    str_passFragment    = 'passFragment',
    str_fragmentChange  = 'fragmentChange',
    str_hashchange      = 'hashchange.' + str_fragmentChange,
    
    // fragmentChange event handler
    timeout_id,
    last_fragment;
  
  
  // A few commonly used bits, broken out to help reduce minified file size.
  
  function is_string( arg ) {
    return typeof arg === 'string';
  };
  
  function is_object( arg ) {
    return typeof arg === 'object';
  };
  
  function curry() {
    var args = aps.call( arguments ),
      func = args.shift();
    
    return function() {
      return func.apply( this, args.concat( aps.call( arguments ) ) );
    };
  };
  
  // Work-around for an annoying Firefox bug where document.location.hash gets
  // urldecoded by default.
  
  function get_fragment() {
    return loc.href.replace( /^[^#]*#?/, '' );
  };
  
  
  // Method: jQuery.urlTagAttrList
  // 
  // Get the internal "Default URL attribute per tag" list, or augment the list
  // with additional tag-attribute pairs, in case the defaults are insufficient.
  // 
  // This list contains the default attributes for the <jQuery.fn.urlInternal>
  // and <jQuery.fn.urlExternal> methods, as well as the <:urlInternal> and
  // <:urlExternal> selector filters, to determine which URL will be tested for
  // internal- or external-ness. In the <jQuery.fn.queryString>,
  // <jQuery.fn.fragment>, <jQuery.fn.passQueryString> and
  // <jQuery.fn.passFragment> methods, this list is used to determine which URL
  // will be modified.
  // 
  // Default List:
  // 
  //  TAG    - URL ATTRIBUTE
  //  a      - href
  //  img    - src
  //  form   - action
  //  base   - href
  //  script - src
  //  iframe - src
  //  link   - href
  // 
  // Usage:
  // 
  //  jQuery.urlTagAttrList( [ tag_attr_obj ] );                             - -
  // 
  // Arguments:
  // 
  //  tag_attr_obj - (Object) An list of tag names and associated default
  //    attribute names in the format { tag: 'attr', tag: 'attr', ... }.
  // 
  // Returns:
  // 
  //  (Object) The current internal "Default URL attribute per tag" list.
  
  $.urlTagAttrList = p_urlTagAttrList = function( attr_obj ) {
    return $.extend( tag_attributes, attr_obj );
  };
  
  // Initialize the tag_attributes object with some reasonable defaults.
  
  p_urlTagAttrList({
    a: 'href',
    img: 'src',
    form: 'action',
    base: 'href',
    script: 'src',
    iframe: 'src',
    link: 'href'
  });
  
  // Get the default attribute for the specified DOM element, if it exists.
  
  function get_attr( elem ) {
    var n = elem.nodeName;
    return n ? tag_attributes[ n.toLowerCase() ] : '';
  };
  
  
  // Section: URL Internal / External
  // 
  // Method: jQuery.urlInternalHost
  // 
  // Constructs the regular expression that matches an absolute-but-internal
  // URL from the current page's protocol, hostname and port, allowing for
  // an optional hostname (if specified). For example, if the current page is
  // http://benalman.com/anything, specifying an alt_hostname of 'www' would
  // yield this pattern:
  // 
  // > /^http:\/\/(?:www\.)?benalman.com\//i
  // 
  // This pattern will match URLs beginning with both http://benalman.com/ and
  // http://www.benalman.com/. Specifying an empty alt_hostname will disable any
  // alt-hostname matching.
  // 
  // Note that the plugin is initialized by default to an alt_hostname of 'www'.
  // Should you need more control, <jQuery.urlInternalRegExp> may be used to
  // completely override this absolute-but-internal matching pattern.
  // 
  // Usage:
  // 
  //  jQuery.urlInternalHost( [ alt_hostname ] );                            - -
  // 
  // Arguments:
  // 
  //  alt_hostname - (String) An optional alternate hostname to use when testing
  //    URL absolute-but-internal-ness.
  // 
  // Returns:
  // 
  //  (RegExp) The absolute-but-internal pattern, as a RegExp.
  
  $.urlInternalHost = p_urlInternalHost = function( alt_hostname ) {
    alt_hostname = alt_hostname
      ? '(?:' + alt_hostname + '\\.)?'
      : '';
    
    var re = new RegExp( '^' + alt_hostname + '(.*)', 'i' ),
      pattern = '^' + loc.protocol + '//'
        + loc.hostname.replace(re, alt_hostname + '$1')
        //+ 'benalman.com'.replace(re, alt_hostname + '$1') // For testing on stage.benalman.com
        + (loc.port ? ':' + loc.port : '') + '/';
    
    return p_urlInternalRegExp( pattern );
  };
  
  
  // Method: jQuery.urlInternalRegExp
  // 
  // Set or get the regular expression that matches an absolute-but-internal
  // URL.
  // 
  // Usage:
  // 
  //  jQuery.urlInternalRegExp( [ re ] );                                    - -
  // 
  // Arguments:
  // 
  //  re - (String or RegExp) The regular expression pattern. If not passed,
  //    nothing is changed.
  // 
  // Returns:
  // 
  //  (RegExp) The absolute-but-internal pattern, as a RegExp.
  
  $.urlInternalRegExp = p_urlInternalRegExp = function( re ) {
    if ( re ) {
      url_regexp = is_string( re )
        ? new RegExp( re, 'i' )
        : re;
    }
    
    return url_regexp;
  };
  
  
  // Initialize url_regexp with a reasonable default.
  
  p_urlInternalHost( 'www' );
  
  
  // Method: jQuery.isUrlInternal
  // 
  // Test whether or not a URL is internal. Non-navigating URLs (ie. #anchor,
  // javascript:, mailto:, news:, tel:, im: or non-http/-https protocol://
  // links) are not considered internal.
  // 
  // Usage:
  // 
  //  jQuery.isUrlInternal( url );                                           - -
  // 
  // Arguments:
  // 
  //   url - (String) a URL to test the internal-ness of.
  // 
  // Returns:
  // 
  //  (Boolean) true if the URL is internal, false if external, or undefined if
  //  the URL is non-navigating.
  
  $.isUrlInternal = p_isUrlInternal = function( url ) {
    
    // non-navigating: url is nonexistent
    if ( !url ) { return undefined; }
    
    // internal: url is absolute-but-internal (see $.urlInternalRegExp)
    if ( url_regexp.test(url) ) { return TRUE; }
    
    // external: url is absolute (begins with http:// or https://)
    if ( /^https?:\/\//i.test(url) ) { return FALSE; }
    
    // non-navigating: url begins with # or scheme:
    if ( /^(?:#|[a-z\d.-]+:)/i.test(url) ) { return undefined; }
    
    return TRUE;
  };
  
  
  // Method: jQuery.isUrlExternal
  // 
  // Test whether or not a URL is external. Non-navigating URLs (ie. #anchor,
  // mailto:, javascript:, or non-http/-https protocol:// links) are not
  // considered external.
  // 
  // Usage:
  // 
  //  jQuery.isUrlExternal( url );                                           - -
  // 
  // Arguments:
  // 
  //   url - (String) a URL to test the external-ness of.
  // 
  // Returns:
  // 
  //  (Boolean) true if the URL is external, false if internal, or undefined if
  //  the URL is non-navigating.
  
  $.isUrlExternal = p_isUrlExternal = function( url ) {
    var result = p_isUrlInternal( url );
    
    return typeof result === 'boolean'
      ? !result
      : result;
  };
  
  
  // Method: jQuery.fn.urlInternal
  // 
  // Filter a jQuery collection of elements, returning only elements that have
  // an internal URL (as determined by <jQuery.isUrlInternal>). If URL cannot
  // be determined, remove the element from the collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').urlInternal( [ attr ] );                            - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    test internal-ness against. See <jQuery.urlTagAttrList> for a list of
  //    default attributes.
  // 
  // Returns:
  // 
  //  (jQuery) A filtered jQuery collection of elements.
  
  // Method: jQuery.fn.urlExternal
  // 
  // Filter a jQuery collection of elements, returning only elements that have
  // an external URL (as determined by <jQuery.isUrlExternal>). If URL cannot
  // be determined, remove the element from the collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').urlExternal( [ attr ] );                            - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    test external-ness against. See <jQuery.urlTagAttrList> for a list of
  //    default attributes.
  // 
  // Returns:
  // 
  //  (jQuery) A filtered jQuery collection of elements.
  
  p_urlFilter = function( selector, attr ) {
    return this.filter( ':' + selector + (attr ? '(' + attr + ')' : '') );
  };
  
  $.fn[str_urlInternal] = curry( p_urlFilter, str_urlInternal );
  $.fn[str_urlExternal] = curry( p_urlFilter, str_urlExternal );
  
  
  // Method: :urlInternal
  // 
  // Filter a jQuery collection of elements, returning only elements that have
  // an internal URL (as determined by <jQuery.isUrlInternal>). If URL cannot
  // be determined, remove the element from the collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').filter(':urlInternal');                             - -
  //  jQuery('selector').filter(':urlInternal(attr)');                       - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    test internal-ness against. See <jQuery.urlTagAttrList> for a list of
  //    default attributes.
  // 
  // Returns:
  // 
  //  (jQuery) A filtered jQuery collection of elements.
  
  // Method: :urlExternal
  // 
  // Filter a jQuery collection of elements, returning only elements that have
  // an external URL (as determined by <jQuery.isUrlExternal>). If URL cannot
  // be determined, remove the element from the collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').filter(':urlExternal');                             - -
  //  jQuery('selector').filter(':urlExternal(attr)');                       - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    test external-ness against. See <jQuery.urlTagAttrList> for a list of
  //    default attributes.
  // 
  // Returns:
  // 
  //  (jQuery) A filtered jQuery collection of elements.
  
  p_urlFilterSelector = function( func, elem, i, match ) {
    var a = match[3] || get_attr( elem );
    
    return a ? !!func( $(elem).attr(a) ) : FALSE;
  };
  
  $.expr[':'][str_urlInternal] = curry( p_urlFilterSelector, p_isUrlInternal );
  $.expr[':'][str_urlExternal] = curry( p_urlFilterSelector, p_isUrlExternal );
  
  
  // Section: URL Query String / Fragment
  // 
  // Method: jQuery.queryString (deserialize)
  // 
  // Deserialize any params string or the current document's query string into
  // an object. Multiple sequential values will be converted into an array, ie.
  // 'n=a&n=b&n=c' -> { n: ['a', 'b', 'c'] }.
  // 
  // Usage:
  // 
  //  jQuery.queryString( [ params_str ] [ , cast_values ] );                - -
  // 
  // Arguments:
  // 
  //  params_str - (String) A stand-alone params string or a URL containing
  //    params to be deserialized. If omitted, defaults to the current page
  //    query string (document.location.search).
  //  cast_values - (Boolean) If true, converts any numbers or true, false,
  //    null, and undefined to their appropriate literal. Defaults to false.
  // 
  // Returns:
  // 
  //  (Object) The deserialized params string.
  
  // Method: jQuery.queryString (serialize)
  // 
  // Serialize an object into a params string. Arrays will be converted to
  // multiple sequential values, ie. { n: ['a', 'b', 'c'] } -> 'n=a&n=b&n=c'
  // (this method is just a wrapper for jQuery.param).
  // 
  // Usage:
  // 
  //  jQuery.queryString( params_obj );                                      - -
  // 
  // Arguments:
  // 
  //  params_obj - (Object) An object to be serialized. Note: A JSON string (or
  //    some analog) should be used for deep structures, since nested data
  //    structures other than shallow arrays can't be serialized into a query
  //    string in a meaningful way.
  // 
  // Returns:
  // 
  //  (String) A params string with urlencoded data in the format 'a=b&c=d&e=f'.
  
  // Method: jQuery.queryString (build url)
  // 
  // Merge a URL (with or without a pre-existing params) plus any object or
  // params string into a new URL.
  // 
  // Usage:
  // 
  //  jQuery.queryString( url, params [ , merge_mode ] );                    - -
  // 
  // Arguments:
  // 
  //  url - (String) A valid URL, optionally containing a query string and/or
  //    #anchor, or fragment.
  //  params - (String or Object) Either a serialized params string or a data
  //    object to be merged into the URL.
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: params argument will override any params in url.
  //    * 1: any params in url will override params argument.
  //    * 2: params argument will completely replace any params in url.
  // 
  // Returns:
  // 
  //  (String) A URL with urlencoded params in the format 'url?a=b&c=d&e=f'.
  
  // Method: jQuery.fragment (deserialize)
  // 
  // Deserialize any params string or the current document's fragment into an
  // object. Multiple sequential values will be converted into an array, ie.
  // 'n=a&n=b&n=c' -> { n: ['a', 'b', 'c'] }.
  // 
  // Usage:
  // 
  //  jQuery.fragment( [ params_str ] [ , cast_values ] );                   - -
  // 
  // Arguments:
  // 
  //  params_str - (String) A stand-alone params string or a URL containing
  //    params to be deserialized. If omitted, defaults to the current page
  //    fragment (document.location.hash).
  //  cast_values - (Boolean) If true, converts any numbers or true, false,
  //    null, and undefined to their appropriate literal. Defaults to false.
  // 
  // Returns:
  // 
  //  (Object) The deserialized params string.
  
  // Method: jQuery.fragment (serialize)
  // 
  // Serialize an object into a params string. Arrays will be converted to
  // multiple sequential values, ie. { n: ['a', 'b', 'c'] } -> 'n=a&n=b&n=c'
  // (this method is just a wrapper for jQuery.param).
  // 
  // Usage:
  // 
  //  jQuery.fragment( params_obj );                                         - -
  // 
  // Arguments:
  // 
  //  params_obj - (Object) An object to be serialized. Note: A JSON string (or
  //    some analog) should be used for deep structures, since nested data
  //    structures other than shallow arrays can't be serialized into a query
  //    string in a meaningful way.
  // 
  // Returns:
  // 
  //  (String) A params string with urlencoded data in the format 'a=b&c=d&e=f'.
  
  // Method: jQuery.fragment (build url)
  // 
  // Merge a URL (with or without a pre-existing params) plus any object or
  // params string into a new URL.
  // 
  // Usage:
  // 
  //  jQuery.fragment( url, params [ , merge_mode ] );                       - -
  // 
  // Arguments:
  // 
  //  url - (String) A valid URL, optionally containing a query string and/or
  //    #anchor, or fragment.
  //  params - (String or Object) Either a serialized params string or a data
  //    object to be merged into the URL.
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: params argument will override any params in url.
  //    * 1: any params in url will override params argument.
  //    * 2: params argument will completely replace any params in url.
  // 
  // Returns:
  // 
  //  (String) A URL with urlencoded params in the format 'url#a=b&c=d&e=f'.
  
  function p_params( fragment_mode, arg0, arg1, arg2 ) {
    var params;
    
    if ( is_string(arg1) || is_object(arg1) ) {
      // Build URL.
      return build_url( arg0, arg1, arg2, fragment_mode );
      
    } else if ( is_object(arg0) ) {
      // Serialize.
      return $.param( arg0 );
      
    } else if ( is_string(arg0) ) {
      // Deserialize.
      return deserialize( arg0, arg1, fragment_mode );
      
    } else {
      // Deserialize document query string / fragment.
      params = fragment_mode
        ? get_fragment()
        : loc.search;
      
      return deserialize( params, arg0, fragment_mode );
    }
  };
  
  $[str_queryString] = curry( p_params, 0 );
  $[str_fragment]    = curry( p_params, 1 );
  
  // Method: jQuery.fn.queryString
  // 
  // Update URL attribute in one or more elements, merging the current URL (with
  // or without pre-existing params) plus any object or params string into a new
  // URL, which is then set into that attribute. Like <jQuery.queryString (build
  // url)>, but for all elements in a jQuery collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').queryString( [ attr, ] params [ , merge_mode ] );   - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    merge params into. See <jQuery.urlTagAttrList> for a list of default
  //    attributes.
  //  params - (String or Object) Either a serialized params string or a data
  //    object to be merged into the URL.
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: params argument will override any params in attr URL.
  //    * 1: any params in attr URL will override params argument.
  //    * 2: params argument will completely replace any params in attr URL.
  // 
  // Returns:
  // 
  //  (jQuery) The initial jQuery collection of elements, but with modified URL
  //  attribute values.
  
  // Method: jQuery.fn.fragment
  // 
  // Update URL attribute in one or more elements, merging the current URL (with
  // or without pre-existing params) plus any object or params string into a new
  // URL, which is then set into that attribute. Like <jQuery.fragment (build
  // url)>, but for all elements in a jQuery collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').fragment( [ attr, ] params [ , merge_mode ] );      - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    merge params into. See <jQuery.urlTagAttrList> for a list of default
  //    attributes.
  //  params - (String or Object) Either a serialized params string or a data
  //    object to be merged into the URL.
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: params argument will override any params in attr URL.
  //    * 1: any params in attr URL will override params argument.
  //    * 2: params argument will completely replace any params in attr URL.
  // 
  // Returns:
  // 
  //  (jQuery) The initial jQuery collection of elements, but with modified URL
  //  attribute values.
  
  function p_fn_params() {
    var attr,
      params,
      merge_mode,
      args = aps.call( arguments ),
      fragment_mode = args.shift();
    
    if ( is_string(args[1]) || is_object(args[1]) ) {
      attr = args.shift();
    }
    params = args.shift();
    merge_mode = args.shift();
    
    return this.each(function(){
      
      var that = $(this),
        a = attr || get_attr( this ),
        url = a && that.attr( a ) || '';
      
      url = p_params( fragment_mode, url, params, merge_mode );
      that.attr( a, url );
      
    });
  };
  
  $.fn[str_queryString] = curry( p_fn_params, 0 );
  $.fn[str_fragment]    = curry( p_fn_params, 1 );
  
  // Method: jQuery.passQueryString
  // 
  // Merge a URL (with or without pre-existing params) plus the document query
  // string into a new URL, optionally omitting specified params or parsing the
  // document params with a callback function pre-merge.
  // 
  // Usage:
  // 
  //  jQuery.passQueryString( url [ , parse ] [ , merge_mode ] );            - -
  // 
  // Arguments:
  // 
  //  url - (String) A valid URL, optionally containing a query string and/or
  //    #anchor, or fragment.
  //  parse - (Array or Function) An optional array of key names to -not- merge
  //    into the URL, or a function that returns the object that will be merged
  //    into url (the document params are deserialized and passed to this
  //    function as its only argument).
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: document params will override any params in url.
  //    * 1: any params in url will override document params.
  //    * 2: document params will completely replace any params in url.
  // 
  // Returns:
  // 
  //  (String) A URL with urlencoded params in the format 'url?a=b&c=d&e=f'.
  
  // Method: jQuery.passFragment
  // 
  // Merge a URL (with or without pre-existing params) plus the document
  // fragment into a new URL, optionally omitting specified params or parsing
  // the document params with a callback function pre-merge.
  // 
  // Usage:
  // 
  //  jQuery.passFragment( url [ , parse ] [ , merge_mode ] );               - -
  // 
  // Arguments:
  // 
  //  url - (String) A valid URL, optionally containing a query string and/or
  //    #anchor, or fragment.
  //  parse - (Array or Function) An optional array of key names to -not- merge
  //    into the URL, or a function that returns the object that will be merged
  //    into url (the document params are deserialized and passed to this
  //    function as its only argument).
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: document params will override any params in url.
  //    * 1: any params in url will override document params.
  //    * 2: document params will completely replace any params in url.
  // 
  // Returns:
  // 
  //  (String) A URL with urlencoded params in the format 'url#a=b&c=d&e=f'.
  
  function p_passParams() {
    var args = aps.call( arguments ),
      fragment_mode = args.shift(),
      url = args.shift(),
      params = p_params( fragment_mode );
    
    if ( $.isFunction(args[0]) ) {
      params = args.shift()( params );
    } else if ( $.isArray(args[0]) ) {
      $.each(args.shift(), function(i,v){
        delete params[v];
      });
    }
    
    return p_params( fragment_mode, url, params, args.shift() );
  };
  
  $[str_passQueryString] = curry( p_passParams, 0 );
  $[str_passFragment]    = curry( p_passParams, 1 );
  
  
  // Method: jQuery.fn.passQueryString
  // 
  // Update URL attribute in one or more elements, merging the current URL (with
  // or without pre-existing params) plus the document query string into a new
  // URL (optionally parsing the document params with a callback function
  // pre-merge), which is then set into that attribute. Like
  // <jQuery.passQueryString>, but for all elements in a jQuery collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').passQueryString( [ attr ] [ , parse ] [ , merge_mode ] );  - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    merge params into. See <jQuery.urlTagAttrList> for a list of default
  //    attributes.
  //  parse - (Array or Function) An optional array of key names to -not- merge
  //    into the URL, or a function that returns the object that will be merged
  //    into url (the document params are deserialized and passed to this
  //    function as its only argument).
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: document params will override any params in attr URL.
  //    * 1: any params in attr URL will override document params.
  //    * 2: document params will completely replace any params in attr URL.
  // 
  // Returns:
  // 
  //  (jQuery) The initial jQuery collection of elements, but with modified URL
  //  attribute values.
  
  // Method: jQuery.fn.passFragment
  // 
  // Update URL attribute in one or more elements, merging the current URL (with
  // or without pre-existing params) plus the document fragment into a new URL
  // (optionally parsing the document params with a callback function
  // pre-merge), which is then set into that attribute. Like
  // <jQuery.passFragment>, but for all elements in a jQuery collection.
  // 
  // Usage:
  // 
  //  jQuery('selector').passFragment( [ attr ] [ , parse ] [ , merge_mode ] );     - -
  // 
  // Arguments:
  // 
  //  attr - (String) Optional name of an attribute that will contain a URL to
  //    merge params into. See <jQuery.urlTagAttrList> for a list of default
  //    attributes.
  //  parse - (Array or Function) An optional array of key names to -not- merge
  //    into the URL, or a function that returns the object that will be merged
  //    into url (the document params are deserialized and passed to this
  //    function as its only argument).
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: document params will override any params in attr URL.
  //    * 1: any params in attr URL will override document params.
  //    * 2: document params will completely replace any params in attr URL.
  // 
  // Returns:
  // 
  //  (jQuery) The initial jQuery collection of elements, but with modified URL
  //  attribute values.
  
  function p_fn_passParams() {
    var attr,
      args = aps.call(arguments),
      fragment_mode = args.shift();
    
    if ( is_string(args[0]) ) {
      attr = args.shift();
    }
    
    return this.each(function(){
      
      var that = $(this),
        a = attr || get_attr( this ),
        url = a && that.attr( a ) || '';
      
      url = p_passParams.apply( this, [fragment_mode, url].concat(args) );
      that.attr( a, url );
      
    });
  };
  
  $.fn[str_passQueryString] = curry( p_fn_passParams, 0 );
  $.fn[str_passFragment]    = curry( p_fn_passParams, 1 );
  
  
  // Deserialize a params string, optionally preceded by a url? or ?, or
  // followed by an #anchor (or if fragment_mode, optionally preceded by a url#
  // or #) into an object, optionally casting numbers, null, true, false, and
  // undefined values appropriately.
  
  function deserialize( params, cast_values, fragment_mode ) {
    var p,
      key,
      val,
      obj = {},
      cast_types = { 'null': null, 'true': TRUE, 'false': FALSE },
      decode_uri_component = decodeURIComponent,
      re = fragment_mode
        ? /^.*[#]/
        : /^.*[?]|#.*$/g;
    
    params = params.replace( re, '' ).replace( /\+/g, ' ' ).split('&');
    
    while ( params.length ) {
      
      p = params.shift().split('=');
      key = decode_uri_component( p[0] );
      
      if ( p.length === 2 ) {
        val = decode_uri_component( p[1] );
        
        if ( cast_values ) {
          if ( val && !isNaN(val) ) {
            val = Number( val );
          } else if ( val === 'undefined' ) {
            val = undefined;
          } else if ( cast_types[val] !== undefined ) {
            val = cast_types[val];
          }
        }
        
        if ( $.isArray(obj[key]) ) {
          obj[key].push( val );
        } else if ( obj[key] !== undefined ) {
          obj[key] = [obj[key], val];
        } else {
          obj[key] = val;
        }
        
      } else if ( key ) {
        obj[key] = cast_values
          ? undefined
          : '';
      }
    }
    
    return obj;
  };
  
  // Merge a URL (with or without a pre-existing params string and/or #anchor,
  // or fragment) plus any object or params string into a new URL.
  
  function build_url( url, params, merge_mode, fragment_mode ) {
    var qs,
      re = fragment_mode
        ? /^([^#]*)[#]?(.*)$/
        : /^([^#?]*)[?]?([^#]*)(#?.*)/,
      matches = url.match( re ),
      url_params = deserialize( matches[2], 0, fragment_mode ),
      hash = matches[3] || '';

    if ( is_string(params) ) {
      params = deserialize( params, 0, fragment_mode );
    }
    
    if ( merge_mode === 2 ) {
      qs = params;
    } else if ( merge_mode === 1 ) {
      qs = $.extend( {}, params, url_params );
    } else {
      qs = $.extend( {}, url_params, params );
    }
    
    qs = $.param( qs );
    return matches[1] + ( fragment_mode ? '#' : qs || !matches[1] ? '?' : '' ) + qs + hash;
  };
  
  
  // Method: jQuery.setFragment
  // 
  // Set the document fragment. Will trigger the <fragmentChange> event if 
  // <jQuery.fragmentChange> has been enabled, and the new fragment is actually
  // different than the previous fragment.
  // 
  // Usage:
  // 
  //  jQuery.setFragment( [ params [ , merge_mode ] ] );                     - -
  // 
  // Arguments:
  // 
  //  params - (String or Object) Either a serialized params string or a data
  //    object to set as the current document's fragment. If omitted, sets the
  //    document fragment to # (this may cause your browser to scroll).
  //  merge_mode - (Number) Merge behavior defaults to 0 if merge_mode is not
  //    specified, and is as-follows:
  // 
  //    * 0: params argument will override any params in document fragment.
  //    * 1: any params in document fragment will override params argument.
  //    * 2: params argument will completely replace any params in document
  //      fragment.
  // 
  // Returns:
  // 
  //  Nothing.
  
  $.setFragment = p_setFragment = function( params, merge_mode ) {
    var frag = is_object( params )
      ? p_params( TRUE, params )
      : (params || '').replace( /^#/, '' );
    
    frag = params
      ? build_url( '#' + get_fragment(), '#' + frag, merge_mode, 1 )
      : '#';
    
    //loc.hash = frag; // Safari 3 & Chrome barf if frag === '#'.
    loc.href = loc.href.replace( /#.*$/, '' ) + frag;
  };
  
  
  // Method: jQuery.fragmentChange
  // 
  // Enable or disable the polling loop that watches the document fragment for
  // changes and triggers the <fragmentChange> event. The event object passed to
  // a bound event callback has the property "fragment" which contains the
  // fragment params string. Disabled by default.
  // 
  // In browsers that support it, the onhashchange event is used (IE8, FF3.6)
  // 
  // Note: When this is enabled for the first time, a hidden IFRAME is written
  // into the body for Internet Explorer 6 and 7 to enable fragment-based
  // browser history.
  // 
  // Usage:
  // 
  //  jQuery.fragmentChange( [ state ] );                                    - -
  // 
  // Arguments:
  // 
  //  state - (Boolean or Number) If true, a polling loop is started with the
  //    default delay of 100 and the fragmentChange event is enabled. If omitted
  //    or false, the polling loop is stopped and the fragmentChange event is
  //    disabled. A zero-or-greater numeric polling loop delay in milliseconds
  //    may also be specified.
  // 
  // Returns:
  // 
  //  Nothing.
  
  // Event: fragmentChange
  // 
  // Fired when the document fragment changes, provided <jQuery.fragmentChange>
  // has been enabled.
  // 
  // The event object that is passed as the sole argument to the callback has a
  // .fragment property, which is a URI encoded string reflecting the current
  // location.hash, with any leading # removed. Using e.fragment should be more
  // reliable than accessing location.hash directly, as only Firefox URI decodes
  // the location.hash property automatically.
  // 
  // Usage:
  // 
  // > $(document).bind('fragmentChange', function(e) {
  // >   var fragment_str = e.fragment,
  // >     fragment_obj = $.fragment();
  // >   ...
  // > });
  
  $[str_fragmentChange] = function( delay ) {
    if ( delay === TRUE ) { delay = 100; }
    
    function trigger() {
      var event = $.Event( str_fragmentChange );
      event[str_fragment] = get_fragment();
      
      $(document).trigger( event );
    };
    
    has_onhashchange && $(window).unbind( str_hashchange );
    
    timeout_id && clearTimeout( timeout_id );
    timeout_id = null;
    
    if ( typeof delay === 'number' ) {
      if ( has_onhashchange ) {
        $(window).bind( str_hashchange, trigger );
        
      } else {
        last_fragment = get_fragment();
        
        if ( $.isFunction(ie_history) ) {
          ie_history = ie_history();
        }
        
        (function loopy(){
          var frag = get_fragment(),
            ie_frag = ie_history[str_fragment]( last_fragment );
          
          if ( frag !== last_fragment ) {
            ie_history[str_update]( frag, ie_frag );
            
            last_fragment = frag;
            trigger();
            
          } else if ( ie_frag !== last_fragment ) {
            p_setFragment( ie_frag, 2 );
          }
          
          timeout_id = setTimeout( loopy, delay < 0 ? 0 : delay );
        })();
      }
    }
  };
  
  // Handle fragment-based browser history in IE 6-7.
  
  function ie_history() {
    var iframe,
      browser = $.browser,
      that = {};
    
    that[str_update] = that[str_fragment] = function( val ){ return val; };
    
    if ( browser.msie && browser.version < 8 ) {
      
      that[str_update] = function( frag, ie_frag ) {
        var doc = iframe.document;
        if ( frag !== ie_frag ) {
          doc.open();
          doc.close();
          doc.location.hash = '#' + frag;
        }
      };
      
      that[str_fragment] = function() {
        return iframe.document.location.hash.replace( /^#/, '' );
      };
      
      iframe = $('<iframe/>').hide().appendTo( 'body' )
        .get(0).contentWindow;
      
      that[str_update]( get_fragment() );
    }
    
    return that;
  };
  
})(jQuery);

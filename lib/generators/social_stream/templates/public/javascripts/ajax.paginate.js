$(function(){

    $('#search_field').live('click',function(){
        if(this.value=="Search by name"){
            this.value="";
        }
    });

    $('#search_field').keypress(function(event){
        if(event.keyCode == '13'){
            $('#list_users_ajax').html("<div id='ajax_loader_icon'><img src='../images/loader.gif'></div>");
            $.getScript(window.location.pathname+"?search="+this.value+"");
        }
    });

    $('#search_button').click(function(){
        e = $.Event('keypress');
        e.keyCode = 13;
        $('#search_field').trigger(e);
    });

    $('.pagination a').live('click',function(){
        $('#list_users_ajax').html("<div id='ajax_loader_icon'><img src='../images/loader.gif'></div>");
        $.setFragment({ "page" : $.queryString(this.href).page });
        $.getScript(this.href);
        return false;
    });

    $('.user_letter_link').live('click',function(){
        $('#list_users_ajax').html("<div id='ajax_loader_icon'><img src='../images/loader.gif'></div>");
        $.setFragment({ "page" : $.queryString(this.href).page });
        $.setFragment({ "letter" : $.queryString(this.href).letter });
        $.getScript(this.href);
        return false;
    });

    $.fragmentChange(true);
    $(document).bind("fragmentChange.page", function() {
        $.getScript($.queryString(document.location.href, { "page" : $.fragment().page,
                                                            "letter": $.fragment().letter}));
    });
    $(document).bind("fragmentChange.letter", function() {
        $.getScript($.queryString(document.location.href, { "page" : $.fragment().page,
                                                            "letter": $.fragment().letter}));
    });

    if ($.fragment().page) {
        $(document).trigger("fragmentChange.page");
    }
    if ($.fragment().letter) {
        $(document).trigger("fragmentChange.letter");
    }
});
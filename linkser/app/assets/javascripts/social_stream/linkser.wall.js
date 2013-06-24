//= require social_stream/callback
//= require social_stream/wall

SocialStream.Linkser.Wall = (function(SS, $) {
  var callback = new SS.Callback();
  var regexp = /^(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&;:\/~+#-]*[\w@?^=%&;\/~+#-])?$/

  var urlDetect = function() {
    this.currentValue = $("#post_text").val();

    if (this.lastValue === null) {
      this.lastValue = "";
    }

    if (regexp.test($("#post_text").val())) {
      $('#post_text').data('link', true);

      $("#link_url").val($("#post_text").val());
      $("#link_loaded").val(false);
      SS.Wall.changeAction($('#link_preview_loading').attr('data-link_path'));
      SS.Wall.changeParams('link');

      if(this.currentValue != this.lastValue) {
        showLoading();

        this.lastValue = this.currentValue;
        var url = this.currentValue;
        var urlDetect = this;

        $.ajax({
          type : "GET",
          url : "/linkser_parse?url=" + url,
          dataType: 'html',
          success : function(html) {
            if($("#post_text").val() == url) {//Only show if input value is still the same
              $("#link_preview").html(html);
              $("#link_loaded").val(true);
            }
          },
          error : function(xhr, ajaxOptions, thrownError) {
            if($("#post_text").val() == url) {//Only show if input value is still the same
              $("#link_preview").html($('<div>').addClass('loading').html(I18n.t('link.errors.loading') + " " + url));
            }
          }
        });
      }

      $("#link_preview").show();
    } else {
      if ($('#post_text').data('link')) {
        $('#post_text').data('link', false);
        resetWallInput();
      }
    }
  };

  var resetWallInput = function() {
    $("#link_preview").hide().html('');
    $("#link_url").val("");
    SS.Wall.changeAction();
    SS.Wall.changeParams('post');
  };

  var showLoading = function() {
    $('#link_preview').html($('#link_preview_loading').html());
  };

  var init = function(){
    $('#link_preview_loading').hide();

    if ($("#new_post").length) {
      $("#post_text").change(urlDetect).keyup(urlDetect);

      $("#post_text").after(
        $('<div>', {
          id: 'link_preview'
        }).css('display', 'none')
      );
    }
  };


  SS.Wall.callbackRegister('show', init);

  callback.register('new_',
                    SS.Wall.new_,
                    resetWallInput);
  
  return callback.extend({
  });

})(SocialStream, jQuery);

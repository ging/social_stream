class LinkserController < ApplicationController
  def index
    if params[:url].present?
      url = params[:url]
      o = Linkser.parse url, {:max_images => 1}
      if o.is_a? Linkser::Objects::HTML
        link = Link.new
        link.title = o.title if o.title
        link.description = o.description if o.description
        link.url = o.last_url
        if o.ogp and o.ogp.image
          link.image = o.ogp.image
        elsif o.images and o.images.first
          link.image = o.images.first.url
        end
        render :partial => "links/link_preview", :locals => {:link => link}
        return
      end
    end    
        render :text => I18n.t("link.errors.only_web")
  end
end

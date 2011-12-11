class LinkserController < ApplicationController
  def index
    if params[:url].present?
      url = params[:url]
      o = Linkser.parse url, {:max_images => 1}
      if o.is_a? Linkser::Objects::HTML
        link = Link.new
        link.fill o
        render :partial => "links/link_preview", :locals => {:link => link}
        return
      end
    end    
        render :text => I18n.t("link.errors.only_web")
  end
end

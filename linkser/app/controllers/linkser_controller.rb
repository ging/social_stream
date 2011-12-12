class LinkserController < ApplicationController
  def index
    if params[:url].present?
      url = params[:url]
      begin
        o = Linkser.parse url, {:max_images => 1}
        if o.is_a? Linkser::Objects::HTML
          link = Link.new
          link.fill o
          render :partial => "links/link_preview", :locals => {:link => link}
          return
        end
      rescue
        render :partial => "links/error", :locals => {:message => I18n.t("link.errors.loading") + " " + url.to_s}     
        return   
      end
    end    
    render :partial => "links/error", :locals => {:message => I18n.t("link.errors.only_webs")}
  end
end

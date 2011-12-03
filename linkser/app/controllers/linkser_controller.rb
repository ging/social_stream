class LinkserController < ApplicationController
  def index
    if params[:url].present?
      url = params[:url]
      linkser_object = Linkser.parse url
      if linkser_object.is_a? Linkser::Objects::HTML
        link = Link.new
        link.title = linkser_object.title
        link.description = linkser_object.description
        link.url = linkser_object.url
        if linkser_object.ogp and linkser_object.ogp.image
          link.image = linkser_object.ogp.image
        elsif linkser_object.images and linkser_object.images.first
          link.image = linkser_object.images.first.url
        end
        render link
        return
      end
    end    
        render :text => "catacrocker"
  end
end

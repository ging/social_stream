class PicturesController < DocumentsController
  before_filter :default_style

  protected
  def default_style
    params[:style] ||= 'original'
  end
end  

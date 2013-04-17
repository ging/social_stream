module PostsHelper
  def try_highlight(text, options = {})
    options[:length] ||= 100

    e = excerpt(text, params[:q].strip, radius: options[:length]) ||
      truncate(text, length: options[:length])

    highlight(e, params[:q])
  end
end

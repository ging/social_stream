module LayoutsHelper
  def content_section_class
    if !content_for?(:toolbar)
      'content-full'
    elsif !content_for?(:sidebar)
      'content-large'
    else
      'content-short'
    end
  end
end

module TagsHelper
  def tag_list taggable
    ''.html_safe.tap do |safe_string|
      taggable.tags.
        map(&:name).
        map{ |t| 
          safe_string << '<span rel="tag">'.html_safe
          safe_string << t
          safe_string << '</span>'.html_safe
        }
    end
  end
end
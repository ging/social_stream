module LocationHelper
  
  # Renders the location stack for your view. You can add as many stack levels as you wish.
  #
  # Usage:  
  # <%= location(level1,leve2,level3,level4,....) %> 
  #
  # Output: 
  # base > level1 > level2 > level3 > level 4
  #
  # Default configuration:
  # base => "You are here" ("location.base" on config/locales)
  # separator => ">" ("location.separator" on config/locales)
  #
  # Styles and HTML wrapping:
  # partial => location/_location.html.erb 
  #
  # Example:  
  # 	Render a location with two leves depth:
  #
  #   	<%= location(link_to(leve1.name, level1.url),link_to(leve2.name, level2.url)) %>
  #
  def location(*stack)
    
    location_body = '<div class="last">' + stack.last + '</div>'
    
    if stack.count >1
      location_body.insert(0, '<div class="penultimate">'+ stack.last(2).first + '</div>')
    end
    
    if stack.count >2   
      stack.first(stack.count - 2).reverse.collect {|level|
        location_body.insert(0, '<div class="mid">'+ level + '</div>')
      }
    end
    
    if stack.count ==1
      location_body.insert(0, '<div class="first"><span class="penultimate">'+ t('location.base') + '</span></div>')
    else
      location_body.insert(0, '<div class="first"><span class="mid">'+ t('location.base') + '</span></div>')
    end
    
    location_div = capture do
      render :partial => "location/location", :locals=>{:location_body => location_body}
    end
    
    case request.format
      when Mime::JS
      response = <<-EOJ

          $('#map_location').html("#{ escape_javascript(location_div) }");
          EOJ
      
      response.html_safe
    else
      content_for(:location) do
        location_div
      end
    end
    
  end
end

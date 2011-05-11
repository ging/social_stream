module NotificationsHelper
  
  def encode_link_to_model object, label = nil
    label ||= object.to_s
    "[a," + label + "," + object.class.to_s + ":" + object.id.to_s + "]"
  end
  
  def decode_notification text
    text.gsub(/\[a,[^\[]*,[^\[]*\]/) {|link|
      data = link.match /\[a,(.*),(.*)\]/
      label = data[1]
      object_class = data[2].split(':')[0]
      object_id = data[2].split(':')[1]
      object = eval(object_class).find_by_id(object_id)
      object = object.subject if object.is_a? Actor 
      link_to label,object
    }
  end
  
end

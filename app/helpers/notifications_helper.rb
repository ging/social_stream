module NotificationsHelper
  def encode_link_to_model object, label = nil
    label ||= object.class.to_s.downcase
    obj_class = object.class.to_s
    obj_id = object.nil? ? "0" : object.id.to_s
    "[a," + label + "," + obj_class + ":" + obj_id + "]"
  end

  def decode_notification text
    text.gsub(/\[a,[^\[]*,[^\[]*\]/) {|link|
      data = link.match /\[a,(.*),(.*)\]/
      label = data[1]
      obj_class = data[2].split(':')[0]
      obj_id = data[2].split(':')[1]       
      if obj_class.eql? NilClass.to_s  
        label
      else
        obj = eval(obj_class).find_by_id(obj_id)
        obj = obj.subject if obj.is_a? Actor
        link_to(label,obj)
      end
    }
  end

end

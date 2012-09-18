# Create new Paperclip::Interpolations method for subtype class
module Paperclip::Interpolations #:nodoc:
  def subtype_class attachment, style_name
    attachment.instance.actor.subject_type.to_s.underscore
  end
end

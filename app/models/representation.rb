# Users can represent other subjects in the application, acting as them
# through the browser, posting new activities, establishing new ties, etc.
class Representation
  extend ActiveModel::Naming
  include ActionController::RecordIdentifier

  attr_reader :subject

  # Sets up new representation
  #
  # params[:subject] must contain the dom_id of the represented subject
  def initialize arg
    @subject =
      case arg
      when Hash
        arg[:subject_dom_id] =~ /(.*)_(\d*)$/

        subject_type = $1.classify.constantize
        subject_id   = $2.to_i

        subject_type.find subject_id
      else
        arg
      end
  end

  def subject_dom_id
    dom_id(subject)
  end

  # ActiveRecord compatibility
  def to_key #:nodoc:
    nil
  end
end

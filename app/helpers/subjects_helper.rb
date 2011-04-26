module SubjectsHelper
  # Return a link to this subject with the name
  def link_name(subject, options = {})
    link_to subject.name, subject, options
  end
end

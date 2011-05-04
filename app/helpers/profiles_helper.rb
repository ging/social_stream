module ProfilesHelper
  
  #Tells if the current subject accessing the profile is its owner or not
  def is_owner?
    if (current_subject.present?) and (@profile.present?) and (@profile.actor == current_subject.actor)
      return true
    else
      return false
    end
  end
  
  #Returns true if the "Personal Information" section is empty
  def is_personal_empty?
    if (@profile.organization?) or (@profile.birthday?) or (@profile.city?) or (@profile.description?)
      return false
    else
      return true
    end
  end
  
  #Returns true if the "Personal Information" section is empty
  def is_contact_empty?
    if (@profile.phone?) or (@profile.mobile?) or (@profile.fax?) or (@profile.address?)or 
       (@profile.website?) or (@profile.subject.email?)
      return false
    else
      return true
    end
  end
  
end
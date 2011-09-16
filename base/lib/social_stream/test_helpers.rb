module SocialStream
  module TestHelpers
    # Represent this subject
    def represent(subject)
      session[:subject_type] = subject.class.to_s
      session[:subject_id] = subject.id

      subject
    end
  end
end

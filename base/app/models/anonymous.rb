class Anonymous < Actor
  class << self
    def instance
      first || create!(:name => "Anonymous",
                       :subject_type => "Anonymous",
                       :notify_by_email => false)
    end
  end

end

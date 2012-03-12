# The {Timeline} is the stream of {Activity Activities} shown in two pages at
# least, the {HomeController home page}, which gathers the activities from
# the people we follow, and the profile page, which shows the activities some
# {SocialStream::Models::Subject subject} has participated in.
# 
# Each timeline entry represents an activity for a subject
class Timeline < ActiveRecord::Base
  belongs_to :activity
  belongs_to :actor
end

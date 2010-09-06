class ActivityObjectActivity < ActiveRecord::Base
  belongs_to :activity
  belongs_to :activity_object
end

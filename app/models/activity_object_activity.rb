class ActivityObjectActivity < ActiveRecord::Base
  belongs_to :activity, :dependent => :destroy
  belongs_to :activity_object
end

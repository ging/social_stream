class ActivityObjectProperty < ActiveRecord::Base
  belongs_to :activity_object
  belongs_to :property,
             :class_name => "ActivityObject"
end

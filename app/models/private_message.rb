class PrivateMessage < ActiveRecord::Base
  belongs_to :sender,
             :class_name => 'Actor'
  belongs_to :receiver,
             :class_name => 'Actor'
end

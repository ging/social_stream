require 'active_support/concern'

module SocialStream
  module Models
    # {Subject Subjects} are subtypes of {Actor}. {SocialStream} provides two
    # {Subject Subjects}, {User} and {Group}
    #
    # Each {Subject} is defined in +config/initializers/social_stream.rb+
    #
    # This module provides additional features for models that are subjects,
    # extending them. Including the module in each {Subject} model is not required!
    # After declared in +config/initializers/social_stream.rb+, {SocialStream} is
    # responsible for adding subject features to each model.
    module Subject
      extend ActiveSupport::Concern
      
      included do
        belongs_to :actor,
                   :validate => true,
                   :autosave => true
        
        delegate :mailbox, :send_message,
        :reply, :reply_to_sender,
        :reply_to_all, :reply_to_conversation,
        :read_mail, :unread_mail,
        :read_converation,
        :name, :name=,
                 :email, :email=,
                 :permalink,
                 :logo, :logo=,
                 :ties, :sent_ties, :received_ties,
                 :ties_to,
                 :sent_ties_allowing,
                 :pending_ties,
                 :relation, :relations,
                 :actors, :subjects,
                 :suggestions, :suggestion,
                 :home_wall, :profile_wall,
                 :to => :actor!
        
        has_one :profile, :through => :actor
        
        accepts_nested_attributes_for :profile
        
        validates_presence_of :name
        
        scope :alphabetic, includes(:actor).order('actors.name')
        scope :search, lambda{|param|
          joins(:actor).where('actors.name like ?',param)}
        scope :with_sent_ties,     joins(:actor => :sent_ties)
        scope :with_received_ties, joins(:actor => :received_ties)
        scope :distinct_initials, joins(:actor).select('DISTINCT SUBSTR(actors.name,1,1) as initial')
      end
      
      module InstanceMethods
        def actor!
          actor || build_actor(:subject_type => self.class.to_s)
        end
        
        def to_param
          permalink
        end
      end
      
      module ClassMethods
        def find_by_permalink(perm)
          joins(:actor).where('actors.permalink' => perm).first
        end
        
        def find_by_permalink!(perm)
          find_by_permalink(perm) ||
          raise(ActiveRecord::RecordNotFound)
        end 
      end
    end
  end
end

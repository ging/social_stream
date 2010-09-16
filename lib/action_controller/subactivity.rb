module ActionController
  module Subactivity
    private

    def activity
      @activity ||= Activity.find(params[:activity_id])
    end

    def activity!
      activity || raise(ActiveRecord::RecordNotFound)
    end

    def tie
      @tie ||= current_user.ties(:receiver => activity!.receiver,
                                 :relation => activity!.relation).first
    end

    def tie!
      tie || raise(ActiveRecord::RecordNotFound)
    end
  end
end

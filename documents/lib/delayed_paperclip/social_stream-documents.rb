# Monkey-patch https://github.com/jstorimer/delayed_paperclip/issues/67
#
# Remove with delayed_paperclip > 2.4.5.2 ???
require 'delayed_paperclip'

module DelayedPaperclip::Attachment::InstanceMethods
  def process_delayed!
    self.job_is_processing = true
    self.post_processing = true
    reprocess!
    self.job_is_processing = false
  end
end

# Monkey-patch https://github.com/jstorimer/delayed_paperclip/commit/3e0e3451147e96f378cda4695546d9633944cc5c
#
# Remove with delayed_paperclip > 2.4.5.1
require 'delayed_paperclip'

module DelayedPaperclip::Attachment::InstanceMethods
  def post_process_styles_with_processing(*args)
    post_process_styles_without_processing(*args)

    # update_column is available in rails 3.1 instead we can do this to update the attribute without callbacks

    #instance.update_column("#{name}_processing", false) if instance.respond_to?(:"#{name}_processing?")
    if instance.respond_to?(:"#{name}_processing?")
      instance.send("#{name}_processing=", false)
      instance.class.update_all({ "#{name}_processing" => false }, instance.class.primary_key => instance.id)
    end
  end
end

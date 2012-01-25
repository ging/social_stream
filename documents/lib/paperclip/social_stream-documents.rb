# Monkey patch https://github.com/thoughtbot/paperclip/issues/293#issuecomment-2484541
#
# Remove with paperclip > 2.5.0
require 'paperclip'

module Paperclip::ClassMethods
  def has_attached_file name, options = {}
    include Paperclip::InstanceMethods

    if attachment_definitions.nil?
      if respond_to?(:class_attribute)
        self.attachment_definitions = {}
      else
        write_inheritable_attribute(:attachment_definitions, {})
      end
    else
      self.attachment_definitions = self.attachment_definitions.dup
    end

    attachment_definitions[name] = {:validations => []}.merge(options)
    Paperclip.classes_with_attachments << self.name
    Paperclip.check_for_url_clash(name,attachment_definitions[name][:url],self.name)

    after_save :save_attached_files
    before_destroy :prepare_for_destroy
    after_destroy :destroy_attached_files

    define_paperclip_callbacks :post_process, :"#{name}_post_process"

    define_method name do |*args|
      a = attachment_for(name)
      (args.length > 0) ? a.to_s(args.first) : a
    end

    define_method "#{name}=" do |file|
      attachment_for(name).assign(file)
    end

    define_method "#{name}?" do
      attachment_for(name).file?
    end

    validates_each(name) do |record, attr, value|
      attachment = record.attachment_for(name)
      attachment.send(:flush_errors)
    end
  end
end

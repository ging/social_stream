class Document < ActiveRecord::Base
  include SocialStream::Models::Object

  has_attached_file :file, 
                    :url => '/:class/:id.:content_type_extension',
                    :path => ':rails_root/documents/:class/:id_partition/original/:filename.:extension'

  paginates_per 20
  
  validates_attachment_presence :file
  validates_presence_of :title
  
  before_validation(:on => :create) do
    set_title
  end
  
  define_index do
    activity_object_index

    indexes file_file_name, :as => :file_name
  end
  
  class << self 
    def new(*args)
      # If already called from subtype, continue through the stack
      return super if self.name != "Document"

      doc = super
      
      return doc if doc.file_content_type.blank?
      
      if klass = lookup_subtype_class(doc)
        return klass.new *args
      end

      doc
    end

    # Searches for the suitable class based on its mime type
    def lookup_subtype_class(doc)
      SocialStream::Documents.subtype_classes_mime_types.each_pair do |klass, mime_types|
        return klass.to_s.classify.constantize if mime_types.include?(doc.mime_type.to_sym)
      end

      nil
    end
  end

  # The Mime::Type of this document's file
  def mime_type
    Mime::Type.lookup(file_content_type)
  end

  # The type part of the {#mime_type}
  def mime_type_type_sym
    mime_type.to_s.split('/').first.to_sym
  end

  # {#mime_type}'s symbol
  def format
    mime_type.to_sym
  end

 # JSON, generic version for most documents
  def as_json(options)
    {
     :id => id,
     :title => title,
     :description => description,
     :author => author.name,
     :src => options[:helper].polymorphic_url(self, action: :download)
    }
  end
  
  protected

  def set_title
    self.title = file_file_name if self.title.blank?
  end
end

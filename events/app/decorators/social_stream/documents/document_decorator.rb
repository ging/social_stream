if defined?(Document)
  Document.class_eval do
    include SocialStream::Events::Models::Document
  end
end

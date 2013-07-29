# Monkey patches to Ruby on Rails
#
# Use unix file util to prove the content type sent by the browser
class ActionDispatch::Http::UploadedFile
  def initialize_with_magic(*args, &block)
    initialize_without_magic(*args, &block)

    if (unix_file = `which file`.try(:chomp)).present? && File.exists?(unix_file)
      `#{ unix_file } -v 2>&1` =~ /^file-(.*)$/
      version = $1

      @content_type =
        if version >= "4.24"
          `#{ unix_file } -b --mime-type #{ @tempfile.path }`.chomp
        else
          `#{ unix_file } -bi #{ @tempfile.path }`.chomp =~ /(\w*\/[\w+-\.]*)/
          $1
        end
    end
  end

  alias_method_chain :initialize, :magic
end

require 'social_stream/routing/mapper'

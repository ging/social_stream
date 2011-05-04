class AttachmentsController < ApplicationController
  SEND_FILE_METHOD = :default

  def download
    head(:not_found) and return if (attachment = Attachment.find_by_id(params[:id])).nil?
    head(:forbidden) and return unless Attachment.can_be_downloaded?

    path = attachment.file.path(params[:style])
    head(:bad_request) and return unless File.exist?(path) && params[:format].to_s == File.extname(path).gsub(/^\.+/, '')

    send_file_options = { :type => File.mime_type?(path) }

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end
end
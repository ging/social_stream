namespace :social_stream do
  namespace :attachments do
    desc "Set record timestamps to false"
    task :freeze_timestamps => :environment do
      %w(Actor Picture Audio Video).each do |k|
        k.constantize.record_timestamps = false
      end

      ActivityObject.class_eval do
        private
        def allowed_relations; end
      end
    end

    desc "Fix avatar's attachment path from Social Stream < 2.0"
    task :fix => [ :freeze_timestamps, 'paperclip:refresh:missing_styles' ]
  end
end


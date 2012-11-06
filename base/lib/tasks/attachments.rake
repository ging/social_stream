namespace :social_stream do
  namespace :avatars do
    desc "Fix avatar's attachment path from paperclip < 3.0"
    task :fix => :environment do
      dir = "#{ Rails.root }/public/system/logos/"

      Avatar.all.each do |a|
        old_logo_dir = "#{ dir }#{ a.id }/"

        old_logo_contents = Dir["#{ old_logo_dir }*"]

        new_logo_dir = "#{ Rails.root }/public#{ a.logo.to_s.split('original').first }"

        puts "Moving #{ old_logo_dir } to #{ new_logo_dir }"

        FileUtils.mkdir_p new_logo_dir
        FileUtils.mv old_logo_contents, new_logo_dir
      end
    end
  end
end


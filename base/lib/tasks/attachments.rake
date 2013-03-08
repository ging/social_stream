namespace :social_stream do
  namespace :avatars do
    desc "Fix avatar's attachment path from Social Stream < 2.0"
    task :fix => :environment do
      old_dir = "#{ Rails.root }/public/system/avatars/logos"
      new_dir = "#{ Rails.root }/public/system/actors"

      FileUtils.mkdir_p new_dir

      puts "Moving #{ old_logo_dir } to #{ new_logo_dir }"

      FileUtils.mv old_dir, new_dir
    end
  end
end


namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_links

    desc "Add links to populate data"
    task :create_links => :read_environment do
      SocialStream::Population::ActivityObject.new Link do |l|
        l.title = Forgery::LoremIpsum.words(1+rand(4),:random => true)
        l.description = Forgery::LoremIpsum.sentences(1+rand(4), :random => true)
        l.url = "http://#{ Forgery::Internet.domain_name }"
      end
    end
  end
end

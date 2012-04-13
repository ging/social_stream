namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_links

    desc "Add links to populate data"
    task :create_links => :read_environment do
      puts 'Links population'
      links_start = Time.now

      50.times do
        updated = Time.at(rand(Time.now.to_i))
        author = Actor.all[rand(Actor.all.size)]
        owner  = author
        user_author =  ( author.subject_type == "User" ? author : author.user_author )

        d = Link.create! :title => Forgery::LoremIpsum.words(1+rand(4),:random => true),
                         :description => Forgery::LoremIpsum.sentences(1+rand(4), :random => true),
                         :url => "http://#{ Forgery::Internet.domain_name }",
                         :created_at => Time.at(rand(updated.to_i)),
                         :updated_at => updated,
                         :author_id  => author.id,
                         :owner_id   => owner.id,
                         :user_author_id => user_author.id,
                         :_relation_ids => [Relation::Public.instance.id]
        d.save!
      end

      links_end = Time.now
      puts '   -> ' +  (links_end - links_start).round(4).to_s + 's'
    end
  end
end


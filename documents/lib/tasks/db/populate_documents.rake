namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_documents

    desc "Add documents to populate data"
    task :create_documents => :read_environment do
      puts 'Documents population'
      docs_start = Time.now

      doc_files = Forgery::Extensions::Array.new(Dir.glob(File.join(Rails.root, 'lib', 'documents', "*")))

      50.times do
        updated = Time.at(rand(Time.now.to_i))
        author = Actor.all[rand(Actor.all.size)]
        owner  = author
        user_author =  ( author.subject_type == "User" ? author : author.user_author )

        d = Document.create! :file => File.open(doc_files.random, "r"),
                             :title => Forgery::LoremIpsum.words(1+rand(4),:random => true),
                             :created_at => Time.at(rand(updated.to_i)),
                             :updated_at => updated,
                             :author_id  => author.id,
                             :owner_id   => owner.id,
                             :user_author_id => user_author.id,
                             :relation_ids => [Relation::Public.instance.id]
        d.save!
      end

      docs_end = Time.now
      puts '   -> ' +  (docs_end - docs_start).round(4).to_s + 's'
    end
  end
end


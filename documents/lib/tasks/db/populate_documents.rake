namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_documents

    desc "Add documents to populate data"
    task :create_documents => :read_environment do
      doc_files = Forgery::Extensions::Array.new(Dir.glob(File.join(Rails.root, 'lib', 'documents', "*")))

      if doc_files.empty?
        puts "     **** Try and place some documents at #{File.join(Rails.root, 'lib', 'documents').to_s} to make db:populate:create_documents work ****"
      else
        SocialStream::Population::ActivityObject.new Document do |d|
          d.file  = File.open(doc_files.random, "r")
          d.title = Forgery::LoremIpsum.words(rand(4), :random => true)
          d.description = Forgery::LoremIpsum.sentences(rand(4), :random => true)
        end
      end
    end
  end
end

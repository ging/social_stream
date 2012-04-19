namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_documents

    desc "Add documents to populate data"
    task :create_documents => :read_environment do
      doc_files = Forgery::Extensions::Array.new(Dir.glob(File.join(Rails.root, 'lib', 'documents', "*")))

      SocialStream::Population::ActivityObject.new Document do |d|
        d.file  = File.open(doc_files.random, "r")
        d.title = Forgery::LoremIpsum.words(rand(4), :random => true)
        d.description = Forgery::LoremIpsum.sentences(rand(4), :random => true)
      end
    end
  end
end

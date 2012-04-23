namespace :db do
  namespace :populate do

    desc "Create populate data with documents"
    task :create => :create_documents

    desc "Add documents to populate data"
    task :create_documents => :read_environment do
      SS_DOCS_PATH=Gem::Specification.find_by_name('social_stream-documents').full_gem_path
      doc_files = Forgery::Extensions::Array.new(Dir.glob(File.join(SS_DOCS_PATH, 'lib', 'samples', "*")))

      SocialStream::Population::ActivityObject.new Document do |d|
        d.file  = File.open(doc_files.random, "r")
        d.title = Forgery::LoremIpsum.words(rand(4), :random => true)
        d.description = Forgery::LoremIpsum.sentences(rand(4), :random => true)
      end
    end
  end
end

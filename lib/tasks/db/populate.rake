namespace :db do
  desc 'Populate database with fake data for development'
  task :populate => [ 'db:seed', 'db:populate:create' ]

  namespace :populate do

    desc "Reload populate data"
    task :reload => [ 'db:reset', :create ]

    desc "Create populate data"
    task :create => :environment do

      LOGOS_PATH = File.join(Rails.root, 'lib', 'logos')

      def set_logos(klass)
        klass.all.each do |i|
          logo = Dir[File.join(LOGOS_PATH, klass.to_s.tableize, "#{ i.id }.*")].first

          if logo.present? && File.exists?(logo)
            i.logo = File.new(logo)
            i.logo.reprocess!
            i.save!
          end
        end
      end

      # = Users

      # Create demo user if not present
      if User.find_by_name('demo').blank?
        User.create! :name => 'Demo',
                     :email => 'demo@social-stream.dit.upm.es',
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end

      require 'forgery'

      9.times do
        User.create! :name => Forgery::Name.full_name,
                     :email => Forgery::Internet.email_address,
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end

      set_logos(User)

      # = Groups
      available_actors = Actor.all

      10.times do
        founder = available_actors[rand(available_actors.size)]

        Group.create :name  => Forgery::Name.company_name,
                     :email => Forgery::Internet.email_address,
                     :_founder => founder.permalink
      end

      set_logos(Group)

      # Reload actors to include groups
      available_actors = Actor.all

      # = Ties
      available_actors.each do |a|
        actors = available_actors.dup - Array(a)
        relations = a.relations

        Forgery::Basic.number(:at_most => actors.size).times do
          actor = actors.delete_at((rand * actors.size).to_i)
          a.sent_ties.create :receiver => actor,
                             :relation => relations.random
        end
      end

      # = Posts

      SocialStream::Populate.power_law(Tie.all) do |t|
        updated = Time.at(rand(Time.now))

        p = Post.create :text =>
                      "This post should be for #{ t.relation.name } of #{ t.sender.name }.\n#{ Forgery::LoremIpsum.paragraph(:random => true) }",
                        :created_at => Time.at(rand(updated)),
                        :updated_at => updated,
                        :_activity_tie_id => t.id

        p.post_activity.update_attributes(:created_at => p.created_at,
                                          :updated_at => p.updated_at)
      end
    end
  end
end

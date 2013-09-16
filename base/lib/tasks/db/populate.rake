namespace :db do
  desc 'Populate database with fake data for development'
  task :populate => 'db:populate:reload'

  namespace :populate do

    desc "Reload populate data"
    task :reload => [ 'db:reset', :create ]

    desc "Reload populate data for Cheesecake testing"
    task :cheesecake => [ 'db:reset', :read_environment, 'create:users', 'create:groups', 'create:cheesecake_ties', 'create:avatars' ]

    desc "Create populate data"
    task :create => [ :read_environment, 'db:seed', 'create:users', 'create:groups', 'create:ties', 'create:posts', 'create:messages', 'create:avatars' ]

    desc "INTERNAL: read needed environment data and setup variables"
    task :read_environment => :environment do
      require 'forgery'

      @SS_BASE_PATH = Gem::Specification.find_by_name('social_stream-base').full_gem_path
      @LOGOS_PATH = File.join(@SS_BASE_PATH, 'lib', 'logos')
      @LOGOS_TOTAL = (ENV["LOGOS_TOTAL"] || 12).to_i
      @USERS = (ENV["USERS"] || 9).to_i
      @GROUPS = (ENV["GROUPS"] || 10).to_i
      if ENV["HARDCORE"].present?
        @USERS = 999
        @GROUPS = 1000
        puts "Hardcore mode: ON (May the Force be with you brave Padawan)"
      end
      if @USERS < 9
        @USERS = 9
        puts "WARNING: There should be at least 10 users (Demo user and 9 more). Changing USERS to 9."
      end
      if @GROUPS < 10
        @GROUPS = 10
        puts "WARNING: There should be at least 10 groups. Changing GROUPS to 10."
      end

      Mailboxer.setup do |config|
        config.uses_emails = false
      end
    end

    namespace :create do
      # USERS
      desc "Create users"
      task :users => :read_environment do
        SocialStream::Population.task "User population (Demo and #{ @USERS } users more)" do

          # Create demo user if not present
          if Actor.find_by_slug('demo').blank?
            u = User.create! :name => '<Demo>',
                             :email => 'demo@social-stream.dit.upm.es',
                             :password => 'demonstration',
                             :password_confirmation => 'demonstration'
            u.actor!.update_attribute :slug, 'demo'
          end

          @USERS.times do
            User.create! :name => Forgery::Name.full_name,
                         :email => Forgery::Internet.email_address,
                         :password => 'demonstration',
                         :password_confirmation => 'demonstration'
          end

          # Reload actors to include new users
          @available_actors = Actor.all
        end
      end


      # GROUPS
      desc "Create groups"
      task :groups => :read_environment do
        SocialStream::Population.task "Groups population (#{ @GROUPS } groups)" do
          @GROUPS.times do
            founder = @available_actors[rand(@available_actors.size)]

            Group.create! :name  => Forgery::Name.company_name,
                          :email => Forgery::Internet.email_address,
                          :author_id => founder.id,
                          :user_author_id => founder.id
          end

          # Reload actors to include groups
          @available_actors = Actor.all
        end
      end

      desc "Populate profiles"

      task :profiles => :read_environment do
        SocialStream::Population.task "Profiles population" do
          SocialStream::Population::Actor.available.each do |a|
            p = a.profile

            if rand < 0.2
              a.tag_list = Forgery::LoremIpsum.words(3, random: true).gsub(' ', ',')
            end

            if rand < 0.2
              p.organization = Forgery::Name.company_name
            end

            if rand < 0.2
              p.birthday = Time.at(Time.now.to_i - (18.years + rand(60.years)))
            end

            if rand < 0.2
              p.city = Forgery::Address.city
            end

            if rand < 0.2
              p.country = Forgery::Address.country
            end

            if rand < 0.2
              p.description = Forgery::LoremIpsum.sentences(2, random: true)
            end

            if rand < 0.2
              p.phone = Forgery::Address.phone
            end

            if rand < 0.2
              p.address = Forgery::Address.street_address
            end

            if rand < 0.2
              p.website = "http://#{ Forgery::Internet.domain_name }"
            end

            if rand < 0.2
              p.experience = Forgery::LoremIpsum.sentences(3, random: true)
            end

            p.save!
          end
        end
      end

      # TIES
      desc "Create ties"
      task :ties => :read_environment do
        SocialStream::Population.task 'Ties population' do
          SocialStream::Population::Actor.available.each do |a|
            actors = SocialStream::Population::Actor.available
            actors.delete(a)

            relations = a.relation_customs + [ Relation::Reject.instance ]

            Forgery::Basic.number(:at_most => actors.size).times do
              actor = actors.delete_at((rand * actors.size).to_i)
              contact = a.contact_to!(actor)
              contact.user_author = a.user_author if a.subject_type != "User"
              contact.relation_ids = [ Forgery::Extensions::Array.new(relations).random.id ]
            end
          end

          Activity.includes(:activity_verb).merge(ActivityVerb.verb_name(["follow", "make-friend"])).each do |a|
            t = SocialStream::Population::Timestamps.new

            a.update_attributes :created_at => t.created,
                                :updated_at => t.updated
          end
        end
      end

      # POSTS
      desc "Create posts"
      task :posts => :read_environment do
        SocialStream::Population::ActivityObject.new Post do |p|
          p.text =
            "This post should be for #{ p.relations.map(&:name).join(", ") } of #{ p.owner.name }.\n#{ Forgery::LoremIpsum.paragraph(:random => true) }"
        end
      end


      # MESSAGES
      desc "Create messages using mailboxer"
      task :messages => :read_environment do
        SocialStream::Population.task 'Mailboxer population' do
          demo = SocialStream::Population::Actor.demo
          @available_actors = Actor.all.sample(Actor.count / 3)
          @available_actors |= [ demo ]


          5.times do
            actors = @available_actors.dup

            mult_recp = actors.uniq

            actor = mult_recp.sample

            mult_recp.delete(actor)

            mail = actor.send_message(mult_recp, "Hello all, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}", Forgery::LoremIpsum.words(10,:random => true))

            [ 'Well', 'Ok', 'Pretty well', 'Finally' ].inject(mail) do |st|
              break if rand < 0.2

              actor = mult_recp.sample

              mail = actor.reply_to_all(mail, "#{ st }, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")

              mail
            end

            if rand > 0.75
              mail.conversation.move_to_trash(demo)
            end

            @available_actors = (Actor.all.sample(Actor.count / 3) - [ demo ])

            @available_actors.each do |a|
              mail = a.send_message(demo, "Hello, #{demo.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}", Forgery::LoremIpsum.words(10,:random => true))
              if rand > 0.5
                mail = demo.reply_to_sender(mail, "Pretty well #{a.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
                if rand > 0.5
                  a.reply_to_sender(mail, "Ok #{demo.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
                end
              end
            end
          end
        end
      end

      # AVATARS
      desc "Create avatars"
      task :avatars => :read_environment do
        def set_logos(klass)
          klass.all.each do |i|
            if @LOGOS_TOTAL
              logo = Dir[File.join(@LOGOS_PATH, klass.to_s.tableize, "#{ rand(@LOGOS_TOTAL) + 1 }.*")].first
              avatar = Dir[File.join(@LOGOS_PATH, klass.to_s.tableize, "#{ rand(@LOGOS_TOTAL) + 1 }.*")].first
            else
              logo = Dir[File.join(@LOGOS_PATH, klass.to_s.tableize, "#{ i.id }.*")].first
              avatar = Dir[File.join(@LOGOS_PATH, klass.to_s.tableize, "#{ i.id }.*")].first
            end

            if avatar.present? && File.exists?(avatar)
              i.logo = File.open(avatar)
              i.save!
            end
          end
        end

        SocialStream::Population.task 'Avatar population' do
          SocialStream.subjects.each {|a| set_logos(Kernel.const_get(a.to_s.classify)) }
        end
      end
    end
  end
end

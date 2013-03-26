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
        puts 'User population (Demo and ' + @USERS.to_s + ' users more)'
        users_start = Time.now

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

        users_end = Time.now
        puts '   -> ' + (users_end - users_start).round(4).to_s + 's'
      end


      # GROUPS
      desc "Create groups"
      task :groups => :read_environment do
        puts 'Groups population (' + @GROUPS.to_s + ' groups)'
        groups_start = Time.now

        def set_tags(klass)
          klass.all.each do |el|
            el.tag_list = Forgery::LoremIpsum.words(1,:random => true)+", "+
                          Forgery::LoremIpsum.words(1,:random => true)+", "+
                          Forgery::LoremIpsum.words(1,:random => true)
            el.save!
          end
        end


        @GROUPS.times do
          founder = @available_actors[rand(@available_actors.size)]

          Group.create! :name  => Forgery::Name.company_name,
                        :email => Forgery::Internet.email_address,
                        :author_id => founder.id,
                        :user_author_id => founder.id
        end

        set_tags(Group)

        # Reload actors to include groups
        @available_actors = Actor.all

        groups_end = Time.now
        puts '   -> ' +  (groups_end - groups_start).round(4).to_s + 's'
      end


      # TIES
      desc "Create ties"
      task :ties => :read_environment do
        puts 'Ties population'
        ties_start = Time.now

        @available_actors.each do |a|
          actors = @available_actors.dup
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

        ties_end = Time.now
        puts '   -> ' +  (ties_end - ties_start).round(4).to_s + 's'
      end


      # TIES, special version for cheesecake testing
      desc "Create cheesecake ties"
      task :cheesecake_ties => :read_environment do
        puts 'Ties population (Cheesecake version)'
        ties_start = Time.now

        @available_actors.each do |a|
          actors = @available_actors.dup - Array(a)
          relations = a.relation_customs + Array.wrap(Relation::Reject.instance)
          break if actors.size==0
          actor = Actor.first
          unless a==actor
            puts a.name + " connecting with " + actor.name
            # DRY! :-S
            contact = a.contact_to!(actor)
            contact.user_author = a.user_author if a.subject_type != "User"
            contact.relation_ids = Array(Forgery::Extensions::Array.new(a.relation_customs).random.id)

            contact = actor.contact_to!(a)
            contact.user_author = actor.user_author if actor.subject_type != "User"
            contact.relation_ids = Array(Forgery::Extensions::Array.new(actor.relation_customs).random.id)
          end
        end

        ties_end = Time.now
        puts '   -> ' +  (ties_end - ties_start).round(4).to_s + 's'
      end


      # POSTS
      desc "Create posts"
      task :posts => :read_environment do
        SocialStream::Population::ActivityObject.new Post do |p|
          p.text =
            "This post should be for #{ p.relations.map(&:name).join(", ") } of #{ p.owner.name }.\n#{ Forgery::LoremIpsum.words(10,:random => true) }"
        end
      end


      # MESSAGES
      desc "Create messages using mailboxer"
      task :messages => :read_environment do
        puts 'Mailboxer population'
        mailboxer_start = Time.now

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

        mailboxer_end = Time.now
        puts '   -> ' +  (mailboxer_end - mailboxer_start).round(4).to_s + 's'

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

        puts 'Avatar population'
        avatar_start = Time.now
        SocialStream.subjects.each {|a| set_logos(Kernel.const_get(a.to_s.classify)) }
        avatar_end = Time.now
        puts '   -> ' +  (avatar_end - avatar_start).round(4).to_s + 's'
      end
    end
  end
end

namespace :db do
  desc 'Populate database with fake data for development'
  task :populate => [ 'db:seed', 'db:populate:create' ]

  namespace :populate do

    desc "Reload populate data"
    task :reload => [ 'db:reset', :create ]

    desc "Create populate data"
    task :create => :environment do

      LOGOS_PATH = File.join(Rails.root, 'lib', 'logos')
      USERS = (ENV["USERS"] || 9).to_i
      GROUPS =  (ENV["GROUPS"] || 10).to_i
      if ENV["HARDCORE"].present?
        USERS = 999
        GROUPS = 1000    
      end
      if USERS < 9
        USERS = 9
        puts "WARNING: There should be at least 10 users (Demo user and 9 more). Changing USERS to 9."
      end
      if GROUPS < 10
        GROUPS = 10
        puts "WARNING: There should be at least 10 groups. Changing GROUPS to 10."
      end

      Mailboxer.setup do |config|
        config.uses_emails = false
      end

      def set_logos(klass)
        klass.all.each do |i|
          logo = Dir[File.join(LOGOS_PATH, klass.to_s.tableize, "#{ i.id }.*")].first
          avatar = Dir[File.join(LOGOS_PATH, klass.to_s.tableize, "#{ i.id }.*")].first

          if avatar.present? && File.exists?(avatar)
            Avatar.copy_to_temp_file(avatar)
            dimensions = Avatar.get_image_dimensions(avatar)
            l = Avatar.new(:actor => i.actor,:logo => File.open(avatar), :name => File.basename(avatar), :crop_x => 0, :crop_y => 0, :crop_w => dimensions[:width], :crop_h => dimensions[:height] )
            l.active = true
            l.save
          end
        end
      end

      def set_tags(klass)
        klass.all.each do |el|
          el.tag_list = Forgery::LoremIpsum.words(1,:random => true)+", "+
                        Forgery::LoremIpsum.words(1,:random => true)+", "+
                        Forgery::LoremIpsum.words(1,:random => true)
          el.save!
        end
      end

      puts 'User population (Demo and ' + USERS.to_s + ' users more)'
      users_start = Time.now

      # = Users

      # Create demo user if not present
      if User.find_by_name('demo').blank?
        User.create! :name => 'Demo',
                     :email => 'demo@social-stream.dit.upm.es',
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end

      require 'forgery'

      USERS.times do
        User.create! :name => Forgery::Name.full_name,
                     :email => Forgery::Internet.email_address,
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end


      users_end = Time.now
      puts '   -> ' + (users_end - users_start).round(4).to_s + 's'

      puts 'Groups population (' + GROUPS.to_s + ' groups)'
      groups_start = Time.now

      # = Groups
      available_actors = Actor.all

      GROUPS.times do
        founder = available_actors[rand(available_actors.size)]

        Group.create! :name  => Forgery::Name.company_name,
                      :email => Forgery::Internet.email_address,
                      :_contact_id => founder.ego_contact.id
      end

      set_tags(Group)

      groups_end = Time.now
      puts '   -> ' +  (groups_end - groups_start).round(4).to_s + 's'


      puts 'Ties population'
      ties_start = Time.now

      # Reload actors to include groups
      available_actors = Actor.all

      # = Ties
      available_actors.each do |a|
        actors = available_actors.dup - Array(a)
        relations = a.relations
        break if actors.size==0
        Forgery::Basic.number(:at_most => actors.size).times do
          actor = actors.delete_at((rand * actors.size).to_i)
          a.contact_to!(actor).relation_ids = Array(Forgery::Extensions::Array.new(relations).random.id)
        end
      end

      ties_end = Time.now
      puts '   -> ' +  (ties_end - ties_start).round(4).to_s + 's'

      # = Posts

      puts 'Post population'
      posts_start = Time.now

      SocialStream::Populate.power_law(Tie.all) do |t|
        updated = Time.at(rand(Time.now.to_i))

        p = Post.create :text =>
                      "This post should be for #{ t.relation.name } of #{ t.sender.name }.\n#{ Forgery::LoremIpsum.paragraph(:random => true) }",
                        :created_at => Time.at(rand(updated.to_i)),
                        :updated_at => updated,
                        :_contact_id => t.contact_id,
                        :_relation_ids => Array(t.relation_id)

        p.post_activity.update_attributes(:created_at => p.created_at,
                                          :updated_at => p.updated_at)
      end

      posts_end = Time.now
      puts '   -> ' +  (posts_end - posts_start).round(4).to_s + 's'

      puts 'Mailboxer population'
      mailboxer_start = Time.now

      # = Mailboxer
      available_actors = Actor.all

      available_actors.each do |a|
        actors = available_actors.dup - Array(a)

        mult_recp = actors.uniq
        if (demo = User.find_by_name('demo')) and !mult_recp.include? Actor.normalize(demo)
          mult_recp << Actor.normalize(demo)
        end
        actor = mult_recp[(rand * mult_recp.size).to_i]
        mult_recp.delete(actor)
        mail = actor.send_message(mult_recp, "Hello all, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}", Forgery::LoremIpsum.words(10,:random => true))
        actor = mult_recp[(rand * mult_recp.size).to_i]
        mail = actor.reply_to_all(mail, "Well, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
        actor = mult_recp[(rand * mult_recp.size).to_i]
        mail = actor.reply_to_all(mail, "Ok, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
        actor = mult_recp[(rand * mult_recp.size).to_i]
        mail = actor.reply_to_all(mail, "Pretty well, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
        actor = mult_recp[(rand * mult_recp.size).to_i]
        actor.reply_to_all(mail, "Finally, I am #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")


        if (demo = User.find_by_name('demo'))
          next if Actor.normalize(demo)==Actor.normalize(a)
          mail = a.send_message(demo, "Hello, #{demo.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}", Forgery::LoremIpsum.words(10,:random => true))
          if rand > 0.5
            mail = demo.reply_to_sender(mail, "Pretty well #{a.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
            if rand > 0.5
              a.reply_to_sender(mail, "Ok #{demo.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
            end
          end
          if rand > 0.75
            mail.conversation.move_to_trash(demo)
          end
        end

        Forgery::Basic.number(:at_most => actors.size).times do
          actor = actors.delete_at((rand * actors.size).to_i)
          next if Actor.normalize(actor)==Actor.normalize(a)
          mail = a.send_message(actor, "Hello, #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}", Forgery::LoremIpsum.words(10,:random => true))
          if rand > 0.5
            mail = actor.reply_to_sender(mail, "Pretty well #{a.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
            if rand > 0.5
              a.reply_to_sender(mail, "Ok #{actor.name}. #{Forgery::LoremIpsum.sentences(2,:random => true)}")
            end
          end
          if rand > 0.75
            mail.conversation.move_to_trash(actor)
          end
        end
      end

      mailboxer_end = Time.now
      puts '   -> ' +  (mailboxer_end - mailboxer_start).round(4).to_s + 's'



      puts 'Avatar population'
      avatar_start = Time.now
      SocialStream.subjects.each {|a| set_logos(Kernel.const_get(a.to_s.classify)) }
      avatar_end = Time.now
      puts '   -> ' +  (avatar_end - avatar_start).round(4).to_s + 's'

    end
  end
end

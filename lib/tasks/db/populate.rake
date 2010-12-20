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

          if File.exist?(logo)
            i.logo = File.new(logo)
            i.logo.reprocess!
            i.save!
          end
        end
      end

      # = Users

      # Create demo user if not present
      if User.find_by_name('demonstration').blank?
        User.create! :name => 'demonstration',
                     :email => 'demonstration@social-stream.dit.upm.es',
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end

      9.times do
        User.create! :name => Forgery::Name.full_name,
                     :email => Forgery::Internet.email_address,
                     :password => 'demonstration',
                     :password_confirmation => 'demonstration'
      end

      set_logos(User)

      available_users = User.all

      # = Groups
      10.times do
        Group.create :name  => Forgery::Name.company_name,
                     :email => Forgery::Internet.email_address
      end

      set_logos(Group)

      available_groups = Group.all

      # = Ties
      available_users.each do |u|
        users = available_users.dup - Array(u)
        user_relations = %w( friend ).map{ |r| Relation.mode('User', 'User').find_by_name(r) }

        Forgery::Basic.number(:at_most => users.size).times do
          user = users.delete_at((rand * users.size).to_i)
          u.sent_ties.create :receiver => user.actor,
                             :relation => user_relations.random
        end

        groups = available_groups.dup
        group_relations = Relation.mode('User', 'Group').all

        Forgery::Basic.number(:at_most => groups.size).times do
          group = groups.delete_at((rand * groups.size).to_i)
          u.sent_ties.create :receiver => group.actor,
                             :relation => group_relations.random
        end
      end

      # = Posts

      SocialStream::Populate.power_law(Tie.all) do |t|
        updated = Time.at(rand(Time.now))

        p = Post.create :text =>
                      "This post should be for #{ I18n.t('other', :scope => t.relation.name) } of #{ t.sender.name }.\n#{ Forgery::LoremIpsum.paragraph(:random => true) }",
                        :created_at => Time.at(rand(updated)),
                        :updated_at => updated,
                        :_activity_tie_id => t.id

        p.post_activity.update_attributes(:created_at => p.created_at,
                                          :updated_at => p.updated_at)
      end
    end
  end
end

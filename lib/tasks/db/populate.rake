namespace :db do
  desc 'Populate database with fake data for development'
  task :populate => [ 'db:seed', 'db:populate:create' ]

  namespace :populate do

    desc "Reload populate data"
    task :reload => [ 'db:reset', :create ]

    desc "Create populate data"
    task :create => :environment do

      # Create demo user if not present
      if User.find_by_name('demostration').blank?
        u = User.create! :name => 'demostration',
                         :email => 'demostration@test.com',
                         :password => 'demostration',
                         :password_confirmation => 'demostration'
      end

      puts "* Create Users"
      20.times do
        u = User.create :name => Forgery::Name.full_name,
                        :email => Forgery::Internet.email_address,
                        :password => 'demostration',
                        :password_confirmation => 'demostration'
      end

      available_users = User.all

      puts "* Create Groups"
      20.times do
        Group.create :name  => Forgery::Name.company_name,
                     :email => Forgery::Internet.email_address
      end

      available_groups = Group.all

      puts "* Create Ties"
      User.all.each do |u|
        users = available_users.dup - Array(u)
        user_relations = %w( Friend FriendOfFriend ).map{ |r| Relation.mode('User', 'User').find_by_name(r) }

        Forgery::Basic.number.times do
          user = users.delete_at((rand * users.size).to_i)
          u.ties.create :receiver => user.actor,
                        :relation => user_relations.random
        end
        groups = available_groups.dup
        group_relations = Relation.mode('User', 'Group')

        Forgery::Basic.number.times do
          group = groups.delete_at((rand * groups.size).to_i)
          u.ties.create :receiver => group.actor,
                        :relation => group_relations.random
        end
      end
    end
  end
end

# encoding: utf-8

namespace :db do
  namespace :populate do

    desc "Create populate data with places"
    task :create => 'create:places'

    namespace :create do
      desc "Add places to populate data"
      task :places => :read_environment do
        puts 'Places population'
        places_start = Time.now
        
        demo = Actor.find_by_slug('demo')
        Place.create  :title          => "Teatro Real",
                      :description    => Forgery::LoremIpsum.sentences(rand(4), :random => true),
                      :streetAddress  => "Plaza Isabel II s/n",
                      :locality       => "Madrid",
                      :region         => "Community of Madrid",
                      :postalCode     => "28013",
                      :country        => "Spain",
                      :phone_number   => "915 16 06 00",
                      :url            => "http://www.teatro-real.com/",
                      :author_id      => demo.id,
                      :owner_id       => demo.id,
                      :user_author_id => demo.id,
                      :relation_ids   => Array(Relation::Public.instance.id)

        Place.create  :title          => "Prado Museum",
                      :description    => Forgery::LoremIpsum.sentences(rand(4), :random => true),
                      :streetAddress  => "Calle Ruiz de Alarcón, 23",
                      :locality       => "Madrid",
                      :region         => "Community of Madrid",
                      :postalCode     => "28014",
                      :country        => "Spain",
                      :phone_number   => "913 30 28 00",
                      :url            => "http://www.museodelprado.es/",
                      :author_id      => demo.id,
                      :owner_id       => demo.id,
                      :user_author_id => demo.id,
                      :relation_ids   => Array(Relation::Public.instance.id)

        Place.create  :title          => "Retiro park",
                      :description    => Forgery::LoremIpsum.sentences(rand(4), :random => true),
                      :streetAddress  => "Plaza Independencia, 7",
                      :locality       => "Madrid",
                      :region         => "Community of Madrid",
                      :postalCode     => "28001",
                      :country        => "Spain",
                      :phone_number   => "915 88 63 92",
                      :url            => "http://www.actividadesambientalesretiro.com/",
                      :author_id      => demo.id,
                      :owner_id       => demo.id,
                      :user_author_id => demo.id,
                      :relation_ids   => Array(Relation::Public.instance.id)

        places_end = Time.now
        puts '  -> ' + (places_end - places_start).round(4).to_s + 's'
      end
    end
  end
end

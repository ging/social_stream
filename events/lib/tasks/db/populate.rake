namespace :db do
  namespace :populate do

    desc "Create populate data with events"
    task :create => 'create:events'

    namespace :create do
      desc "Add events to populate data"
      task :events => :read_environment do
        scope = 2.months

        SocialStream::Population::ActivityObject.new Event do |l|
          l.title = Forgery::LoremIpsum.words(1+rand(4),:random => true)
          l.description = Forgery::LoremIpsum.sentences(1+rand(4), :random => true)

          s = rand(scope)
          s *= -1 if [ true, false ].sample

          l.start_at = Time.at(Time.now.to_i + s)

          if rand(1) > 0.25
            l.start_at = l.start_at.begining_of_day
            l.end_at   = l.start_at.end_of_day
            l.all_day  = true
          else
            l.end_at = l.start_at + rand(3.days)
          end

          l.frequency = [ 0, 2, 3 ].sample

          case l.frequency
          when 2
            l.interval = [ 1, 2, 3 ].sample
            l.week_days = 7.times.map{ |i| i }.sample(rand(6).to_i + 1)
          when 3
            l.week_day_order = [ 1, 2, 3, -1 ].sample
            l.week_day = 7.times.map{ |i| i }.sample
            l.interval = rand(3).to_i + 1
          end
        end
      end
    end
  end
end

module SocialStream
  module Views
    module Settings
      class ItemList < Array
        def insert_before key, obj
          position = index{ |i| i[:key] == 'notifications' } + 1

          insert position, obj
        end
      end
    end
  end
end

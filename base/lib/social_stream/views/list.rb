module SocialStream
  module Views
    class List < Array
      def insert_before key, obj
        position = index{ |i| i[:key] == key }

        insert position, obj
      end

      def insert_after key, obj
        position = index{ |i| i[:key] == key } + 1

        insert position, obj
      end
    end
  end
end

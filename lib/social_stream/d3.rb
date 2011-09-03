module SocialStream
  # Methods for d3.js library
  # http://mbostock.github.com/d3/
  module D3
    class Force
      def initialize(ties, view)
        @view = view

        @force =
          ties.inject({ :nodes => [], :links => [] }) { |result, t|
            add_node(result[:nodes], t.sender)
            add_node(result[:nodes], t.receiver)

            add_link(result[:links], t, result[:nodes])

            result
          }
      end

      def to_json
        @force.to_json
      end

      private

      def node(actor)
        { 
          :name     => actor.name,
          :logo     => @view.image_path(actor.logo.url(:representation)),
          :group    => SocialStream.subjects.index(actor.subject_type.underscore.to_sym) + 1
        }
      end

      def add_node(nodes, actor)
        return if nodes_actor_index(nodes, actor)

        nodes << node(actor)
      end

      def add_link(links, tie, nodes)
        links << {
          :source => nodes_actor_index(nodes, tie.sender),
          :target => nodes_actor_index(nodes, tie.receiver),
          :value  => 1
        }
      end

      def nodes_actor_index(nodes, actor)
        nodes.index(nodes.find{ |n| n[:name] == actor.name })
      end
    end
  end
end

User.class_eval do
  include SocialStream::Oauth2Server::Models::User

  def as_json_with_client options = {}
    hash = as_json_without_client options

    if options[:client] && !options[:client].is_a?(User)
      hash['roles'] = options[:client].contact_to!(self).relations.map{ |r|
        { 
          id: r.id,
          name: r.name
        }
      }
    end

    hash
  end

  alias_method_chain :as_json, :client
end

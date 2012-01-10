module SocialStream
  module Views
    module Settings
      module Base
        def settings_items
          SocialStream::Views::List.new.tap do |items|
            if current_subject  == current_user
              items << {
                :key  => 'user.edit',
                :html => render(:partial => "devise/registrations/edit_user",
                                :locals => {
                                             :resource => current_user,
                                             :resource_name => :user
                                           })
              }
            end

            items << {
              :key  => 'language',
              :html => render(:partial => "language")
            }

            items << {
              :key  => 'notifications',
              :html => render(:partial => "notifications")
            }

            if current_subject.respond_to? :authentication_token
              items << {
                :key  => 'api_key',
                :html => render(:partial => "api_key")
              }
            end

            items << {
              :key  => 'destroy',
              :html => 
                current_subject == current_user ?
                  render(:partial => "devise/registrations/delete_account",
                                     :locals => { :resource => current_user, :resource_name => :user }) :
                  render(:partial => 'destroy')
            }
          end
        end
      end
    end
  end
end

module SocialStream

  autoload :Ability, 'social_stream/ability'
  autoload :ActivityStreams, 'social_stream/activity_streams'

  module ActivityStreams
    autoload :Supertype, 'social_stream/activity_streams/supertype'
    autoload :Subtype,   'social_stream/activity_streams/subtype'
  end

  module Base
    autoload :Ability,   'social_stream/base/ability'
  end

  module Controllers
    autoload :Authorship,              'social_stream/controllers/authorship'
    autoload :Avatars,                 'social_stream/controllers/avatars'
    autoload :MarkNotificationsRead,   'social_stream/controllers/mark_notifications_read'
    autoload :I18nIntegration,         'social_stream/controllers/i18n_integration'
    autoload :CancanDeviseIntegration, 'social_stream/controllers/cancan_devise_integration'
    autoload :Helpers,  'social_stream/controllers/helpers'
    autoload :Objects,  'social_stream/controllers/objects'
    autoload :Subjects, 'social_stream/controllers/subjects'
  end

  autoload :D3,          'social_stream/d3'

  module Devise
    module Controllers
      autoload :UserSignIn, 'social_stream/devise/controllers/user_sign_in'
    end
  end

  module Models
    autoload :Object,    'social_stream/models/object'
    autoload :Subject,   'social_stream/models/subject'
    autoload :Subtype,   'social_stream/models/subtype'
    autoload :Supertype, 'social_stream/models/supertype'
  end

  autoload :Population,  'social_stream/population'

  module Population
    autoload :ActivityObject, 'social_stream/population/activity_object'
    autoload :Actor,          'social_stream/population/actor'
    autoload :PowerLaw,       'social_stream/population/power_law'
    autoload :Timestamps,     'social_stream/population/timestamps'
  end

  autoload :Relations,   'social_stream/relations'

  module Routing
    module Constraints
      autoload :Custom, 'social_stream/routing/constraints/custom'
      autoload :Follow, 'social_stream/routing/constraints/follow'
      autoload :Resque, 'social_stream/routing/constraints/resque'
    end
  end

  autoload :Search, 'social_stream/search'

  autoload :TestHelpers, 'social_stream/test_helpers'

  module TestHelpers
    autoload :Controllers, 'social_stream/test_helpers/controllers'
  end

  module Views
    autoload :List,     'social_stream/views/list'
    autoload :Location, 'social_stream/views/location'
  end
end

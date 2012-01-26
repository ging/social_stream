# Monkey patch https://github.com/fnando/i18n-js/commit/888e9c59dfb5164a85f136705186b02d9ef33d5a
#
# Remove with i18n-js > 2.1.2
require 'i18n-js'

module SimplesIdeias
  module I18n
    class Engine
      initializers.pop

      initializer "i18n-js.asset_dependencies", :after => "sprockets.environment" do
        next unless I18n.has_asset_pipeline?

        config = I18n.config_file
        cache_file = I18n::Engine.load_path_hash_cache

        Rails.application.assets.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, data|
          if context.logical_path == I18N_TRANSLATIONS_ASSET
            context.depend_on(config) if I18n.config?
            # also set up dependencies on every locale file
            ::I18n.load_path.each {|path| context.depend_on(path)}

            # Set up a dependency on the contents of the load path
            # itself. In some situations it is possible to get here
            # before the path hash cache file has been written; in
            # this situation, write it now.
            I18n::Engine.write_hash! unless File.exists?(cache_file)
            context.depend_on(cache_file)
          end

          data
        end
      end
    end
  end
end

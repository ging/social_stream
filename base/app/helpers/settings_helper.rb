module SettingsHelper
  include SocialStream::Views::Settings

  def render_settings
    settings_items.inject(ActiveSupport::SafeBuffer.new) do |result, item|
      result + item[:html]
    end
  end
end

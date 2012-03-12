module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module I18nIntegration
      extend ActiveSupport::Concern

      included do
         before_filter :set_locale
      end

      # Set locale as per params, user preference or default
      def set_locale
        I18n.locale = params[:locale] || user_preferred_locale || session[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
      end

      private
      def extract_locale_from_accept_language_header
        return nil if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
        (request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).map{|l| l.to_sym} & I18n.available_locales).first
      end

      def user_preferred_locale
        current_user.language if user_signed_in?
      end
    end
  end
end

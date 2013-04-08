class SearchController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  RESULTS_SEARCH_PER_PAGE=16

  def index
    @search_result =
      if params[:q].blank? || params[:q].strip.size < SocialStream::Search::MIN_QUERY
        Kaminari.paginate_array([])
      elsif params[:mode] == "quick"
        search :quick
      else
        search :extended
      end

    respond_to do |format|
      format.html {
        if request.xhr?
          if params[:mode] == "quick"
            render partial: "quick"
          else
            if params[:q].present?
              render partial: 'results'
            else
              render partial: 'index'
            end
          end
        end
      }

      format.json {
        json_obj = (
          params[:type].present? ?
          { params[:type].pluralize => @search_result } :
          @search_result
        )

        render :json => json_obj
      }

      format.js
    end
  end

  private

  def search mode
    result = SocialStream::Search.search(params[:q],
                                         current_subject,
                                         :mode => mode,
                                         :key  => params[:type])

    if mode.to_s.eql? "quick"
      result = Kaminari.paginate_array(result).page(1).per(7)
    else
      result = Kaminari.paginate_array(result).page(params[:page]).per(RESULTS_SEARCH_PER_PAGE)
    end

    result
  end
end

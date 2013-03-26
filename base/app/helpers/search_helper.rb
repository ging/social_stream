module SearchHelper  
  def get_search_query_words
    search_query = ""
    bare_query = strip_tags(params[:q]) unless bare_query.html_safe?
    return bare_query.strip.split
  end

  def search_results?(key)
    SocialStream::Search.count(params[:q],
                               current_subject,
                               :key => key) > 0
  end
end

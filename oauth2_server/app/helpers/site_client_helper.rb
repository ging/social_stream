module SiteClientHelper
  # Extract {Site::Client} id form Devise's redirect_to 
  def redirect_to_site_client_id
    uri = URI.parse session["user_return_to"]

    Rack::Utils.parse_query(uri.query)["client_id"]
  rescue
  end

  def redirect_to_site_client?
    redirect_to_site_client_id.present?
  end

  def redirecting_site_client
    Site::Client.find redirect_to_site_client_id
  end
end

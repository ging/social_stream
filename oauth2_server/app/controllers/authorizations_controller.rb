class AuthorizationsController < ApplicationController
  before_filter :authenticate_user!

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    render :error, :status => e.status
  end

  def new
    respond *authorize_endpoint.call(request.env)
  end

  def create
    respond *authorize_endpoint(:allow_approval).call(request.env)
  end

  private

  def respond(status, header, response)
    ["WWW-Authenticate"].each do |key|
      headers[key] = header[key] if header[key].present?
    end

    if response.redirect?
      redirect_to header['Location']
    else
      render :new
    end
  end

  def authorize_endpoint(allow_approval = false)
    Rack::OAuth2::Server::Authorize.new do |req, res|
      @client = Site::Client.find(req.client_id) || req.bad_request!

      res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.callback_url)

      if allow_approval
        if params[:accept]
          current_user.client_authorize!(@client)

          approve!(req, res, @client)
        else
          req.access_denied!
        end
      else
        if current_user.client_authorized?(@client)
          approve!(req, res, @client)
        else
          @response_type = req.response_type
          @state = req.state
        end
      end
    end
  end

  def approve!(req, res, client)
    case req.response_type
    when :code
      authorization_code = current_user.authorization_codes.create!(:client => client, :redirect_uri => res.redirect_uri)
      res.code = authorization_code.token
    when :token
      res.access_token = current_user.access_tokens.create!(:client => client).to_bearer_token
    end

    res.approve!
  end
end

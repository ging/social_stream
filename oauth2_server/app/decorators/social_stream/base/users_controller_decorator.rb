UsersController.class_eval do
  def current
    respond_to do |format|
      format.json { render json: current_user.to_json(client: oauth2_token.try(:client)) }
    end
  end
end

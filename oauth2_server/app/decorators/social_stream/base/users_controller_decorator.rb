UsersController.class_eval do
  def current
    binding.pry
    respond_to do |format|
      format.json { render json: current_user.to_json(client: oauth2_token.try(:client)) }
    end
  end
end

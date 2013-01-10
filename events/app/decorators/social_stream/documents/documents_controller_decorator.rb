DocumentsController.class_eval do
  private

  def allowed_params
    [ :file, :event_property_object_id ]
  end
end

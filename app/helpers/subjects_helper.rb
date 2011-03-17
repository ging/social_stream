module SubjectsHelper
  def toolbar_menu(option = nil, &block)
    if option
      content_for("menu_#{ option }".to_sym, &block)
    end

    content_for(:toolbar) do
      render :partial => 'subjects/toolbar'
    end
  end
end

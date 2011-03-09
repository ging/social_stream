module ApplicationHelper

  def list_skins
    skins = Array.new

    Dir.foreach("#{RAILS_ROOT}/public/stylesheets") do |d|
      if File.directory?("#{RAILS_ROOT}/public/stylesheets/" + d) && d != "." && d != ".."
        skins << d
      end
    end

    skins
  end

  def stylesheet_link_tag(*sources)
    clara_space = Space.root
    spaces = current_user.agent_performances.select {|x| x.stage_type == 'Space'}
    main_space = spaces.count > 0 ? spaces.first.stage : clara_space
    skin = @space ? @space.skin : main_space ? main_space.skin : "default"

    options = sources.extract_options!.stringify_keys
    sources.collect! {|x| skin + "/" + x }

    super sources, options
  end

end




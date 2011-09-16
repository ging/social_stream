module EventHelper

  def wrap_file_name(name)
    name
    if(name.length > 12)
      name[0,12]+"..."
    end
  end



end
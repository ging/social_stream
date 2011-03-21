require 'RMagick'

class Logo < ActiveRecord::Base
      has_attached_file :logo,
                        :styles => { :tie => "30x30>",
                                     :actor => '35x35>',
                                     :profile => '94x94' },
                        :default_url => "/images/:attachment/:style/:subtype_class.png"
     before_post_process :pruebame
     attr_accessor :crop_x, :crop_y, :crop_w, :crop_h	
	
   
   def pruebame
       #debugger
       logo.errors['precrop'] = "You have to make precrop"
	 #logo[:prueba] = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
	
      images_path = File.join(RAILS_ROOT, "public", "images")
      tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
      my_file_name = File.basename(logo.queued_for_write[:original].path)
      FileUtils.cp(logo.queued_for_write[:original].path,tmp_path)
      temp_file = File.open(logo.queued_for_write[:original].path, "w+")

       
   end
   
   def make_precrop(path,x,y,width,height)
     #(rdb:391) eval @logo.make_precrop(@logo.logo.queued_for_write[:original],1,2,2,2)

     #myPath = @logo.logo.queued_for_write[:original].path

     img_orig = Magick::Image.read(path).first
    # img_orig = img_orig.resize_to_fit(600, 600)
     
     crop_args = [x,y,width,height]
     img_orig = img_orig.crop(*crop_args)
     
     img_orig.write(path)
     
  end
 
  def prueba(hash)
     #puts hash[:profile].path
     
     hash.each_value do |aFile|
       #debugger
       puts aFile.path
       #puts aFile[1].path
     end
     puts "\n\n\n"
     
     #puts hash.class
  end
 
 
     
end

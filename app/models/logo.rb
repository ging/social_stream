require 'RMagick'

class Logo < ActiveRecord::Base
 has_attached_file :logo,
                        :styles => { :tie => "30x30>",
                                     :actor => '35x35>',
                                     :profile => '94x94' },
                        :default_url => "/images/:attachment/:style/:subtype_class.png"
	before_post_process :process_precrop
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
	validates_attachment_presence :logo

   def process_precrop
      logo.errors['precrop'] = "You have to make precrop"
	
      images_path = File.join(RAILS_ROOT, "public", "images")
      tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
      
      resize_image(logo.queued_for_write[:original].path,600,600)
 
      my_file_name = File.basename(logo.queued_for_write[:original].path)
      FileUtils.cp(logo.queued_for_write[:original].path,tmp_path)
      temp_file = File.open(logo.queued_for_write[:original].path, "w+")   
   end
   
   def image_dimensions(name)
   	
   	images_path = File.join(RAILS_ROOT, "public", "images")
    tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
   	file_path = File.join(tmp_path,name)
   	
   	img_orig = Magick::Image.read(file_path).first
   	dimensions = {}
   	dimensions[:width] =  img_orig.columns
   	dimensions[:height] = img_orig.rows
   	dimensions
   end
   
   def resize_image(path,width,height)
	img_orig = Magick::Image.read(path).first
   	img_orig = img_orig.resize_to_fit(width, height)
   	img_orig.write(path)
   end
   
   def make_precrop(path,x,y,width,height)
     img_orig = Magick::Image.read(path).first
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


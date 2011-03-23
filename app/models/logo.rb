require 'RMagick'

class Logo < ActiveRecord::Base
 	has_attached_file :logo,
                      :styles => { :tie => "30x30>",
                                   :actor => '35x35>',
                                   :profile => '94x94' },
                      :default_url => "/images/:attachment/:style/:subtype_class.png"
	
	before_post_process :process_precrop
#	before_post_process :copy_temp_file
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :name
	validates_attachment_presence :logo, :if => :uploading_file?
	
	
	after_validation :precrop_done
#	after_validation :mylog
	
	
  def uploading_file?
    return @name.blank?
  end
	
	def precrop_done
		#en este metodo el precrop estará hecho ya y tendremos que crear el nuevo logo sin los errores
	#	puts "+++++++++++++" + @name.to_s + "************"
	#	puts "-------------" + @logo.to_s + "************"
	return if @name.blank?
	
		images_path = File.join(RAILS_ROOT, "public", "images")
    	tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
    	precrop_path = File.join(tmp_path,@name)
    	#debugger
    	
    	make_precrop(precrop_path,@crop_x.to_i,@crop_y.to_i,@crop_w.to_i,@crop_h.to_i)
		@logo = Logo.new :logo => File.open(precrop_path), :name => @name
		
		self.logo = @logo.logo
		
		FileUtils.remove_file(precrop_path)
		
		
	end
	
	
	def copy_temp_file
	  images_path = File.join(RAILS_ROOT, "public", "images")
      tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
	end
	
	def mylog
		
		images_path = File.join(RAILS_ROOT, "public", "images")
    	tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
   		#file_path = File.join(tmp_path,@name)
   		#@logo = Logo.new :logo => File.open(file_path)
		
		debugger
		puts ""
	end

   def process_precrop
   	#debugger
      #puts "+++++++++++++" + @name.to_s + "************"
      puts "--------------------------------------------------"

	return if !@name.blank?
      logo.errors['precrop'] = "You have to make precrop"

	
      images_path = File.join(RAILS_ROOT, "public", "images")
      tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
      
      resize_image(logo.queued_for_write[:original].path,500,500)
 
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
end


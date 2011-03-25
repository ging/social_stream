require 'RMagick'

class Logo < ActiveRecord::Base
 	has_attached_file :logo,
                      :styles => { :tie => "30x30>",
                                   :actor => '35x35>',
                                   :profile => '94x94' },
                      :default_url => "/images/:attachment/:style/:subtype_class.png"
	
	before_post_process :process_precrop
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :name
	validates_attachment_presence :logo, :if => :uploading_file?
		
	after_validation :precrop_done
	
	belongs_to :actor
	
	delegate :url, :to => :logo
	
  	def uploading_file?
    	return @name.blank?
  	end
	
	def precrop_done
		return if @name.blank?
		
#		images_path = File.join(RAILS_ROOT, "public", "images")
#    	tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
    	precrop_path = File.join(Logo.images_tmp_path,@name)
    	
    	make_precrop(precrop_path,@crop_x.to_i,@crop_y.to_i,@crop_w.to_i,@crop_h.to_i)
		@logo = Logo.new :logo => File.open(precrop_path), :name => @name
		
		self.logo = @logo.logo
		
		FileUtils.remove_file(precrop_path)
	end
	
	def self.images_tmp_path
		images_path = File.join(RAILS_ROOT, "public", "images")
		tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))		
	end
	
	def self.copy_to_temp_file(path)
		FileUtils.cp(path,Logo.images_tmp_path)
	end	
	
	
	def self.get_image_dimensions(name)
   		img_orig = Magick::Image.read(name).first
   		dimensions = {}
   		dimensions[:width] =  img_orig.columns
   		dimensions[:height] = img_orig.rows
   		dimensions
   end
	
	def copy_temp_file
	  images_path = File.join(RAILS_ROOT, "public", "images")
      tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
	end

   def process_precrop
   	
  	if @name.blank? && (  logo.content_type.present? && !logo.content_type.start_with?("image/"))
		logo.errors['invalidType'] = "The file you uploaded isn't valid"
		return false
	end
   	
	return if !@name.blank?
      logo.errors['precrop'] = "You have to make precrop"
	
      #images_path = File.join(RAILS_ROOT, "public", "images")
      #tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))
            
      resize_image(logo.queued_for_write[:original].path,500,500)
 
      #my_file_name = File.basename(logo.queued_for_write[:original].path)
      #FileUtils.cp(logo.queued_for_write[:original].path,Logo.images_tmp_path)
      Logo.copy_to_temp_file(logo.queued_for_write[:original].path)
      #temp_file = File.open(logo.queued_for_write[:original].path, "w+")   
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
     dimensions = Logo.get_image_dimensions(path)
     
	if (width == 0) || (height == 0)
		return
	end     
 
     crop_args = [x,y,width,height]
     img_orig = img_orig.crop(*crop_args)
     img_orig.write(path)
  end   
end


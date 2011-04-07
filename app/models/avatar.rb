require 'RMagick'

class Avatar < ActiveRecord::Base
 	has_attached_file :logo,
                      :styles => { :representation => "20x20>",
                                   :tie => "30x30>",
                                   :actor => '35x35>',
                                   :profile => '94x94' },
                      :default_url => "/images/logos/:style/:subtype_class.png"
	
	before_post_process :process_precrop
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :name,:updating_logo
	validates_attachment_presence :logo, :if => :uploading_file?, :message => I18n.t('avatar.error.no_file')
		
	after_validation :precrop_done
	
	belongs_to :actor
	
	scope :active, where(:active => true)
	
  	def uploading_file?
    	return @name.blank?
  	end
	
	def precrop_done
		return if @name.blank? || !@updating_logo.blank?

    	precrop_path = File.join(Avatar.images_tmp_path,@name)
    	
    	make_precrop(precrop_path,@crop_x.to_i,@crop_y.to_i,@crop_w.to_i,@crop_h.to_i)
	   	@avatar = Avatar.new :logo => File.open(precrop_path), :name => @name
		
				
		self.logo = @avatar.logo
		
		FileUtils.remove_file(precrop_path)
	end
	
	def self.images_tmp_path
		images_path = File.join(RAILS_ROOT, "public", "images")
		tmp_path = FileUtils.mkdir_p(File.join(images_path, "tmp"))		
	end
	
	def self.copy_to_temp_file(path)
		FileUtils.cp(path,Avatar.images_tmp_path)
	end	
	
	
	def self.get_image_dimensions(name)
   		img_orig = Magick::Image.read(name).first
   		dimensions = {}
   		dimensions[:width] =  img_orig.columns
   		dimensions[:height] = img_orig.rows
   		dimensions
   end
	
   def process_precrop
   	
  	if @name.blank? && (  logo.content_type.present? && !logo.content_type.start_with?("image/"))
		logo.errors['invalidType'] = I18n.t('avatar.error.no_image_file')
		return false
	end
   	  	
	return if !@name.blank?
      logo.errors['precrop'] = "You have to make precrop"
      resize_image(logo.queued_for_write[:original].path,500,500)
      Avatar.copy_to_temp_file(logo.queued_for_write[:original].path)   
   end
      
   def resize_image(path,width,height)
	  img_orig = Magick::Image.read(path).first
   	img_orig = img_orig.resize_to_fit(width, height)
   	img_orig.write(path)
   end
   
   def make_precrop(path,x,y,width,height)
     img_orig = Magick::Image.read(path).first
     dimensions = Avatar.get_image_dimensions(path)
     
	   unless (width == 0) || (height == 0)
		  crop_args = [x,y,width,height]
      img_orig = img_orig.crop(*crop_args)
	   end     
 
     img_orig = img_orig.resize_to_fill(500,500)
     
     
     img_orig.write(path)
  end   
end


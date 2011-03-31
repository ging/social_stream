module SubjectsHelper
	# Return a link to this subject with the name
	def link_name(subject, options = {})
		link_to subject.name, subject, options
	end

	# Define the toolbar content for your view. There are two typical cases, depending on the value of
	# options[:profile]
	# * If present, render the profile menu for the {SocialStream::Models::Subject subject}
	# * If blank, render the home menu
	#
	# The menu option allows overwriting a menu slot with the content of the given block
	#
	# Examples:
	#
	# Render the home toolbar:
	#
	#   <% toolbar %>
	#
	# Render the profile toolbar for a user:
	#
	#   <% toolbar :profile => @user %>
	#
	# Render the home toolbar changing the messages menu option:
	#
	#   <% toolbar :option => :messages %>
	#
	# Render the profile toolbar for group changing the contacts menu option:
	#
	#   <% toolbar :profile => @group, :option => :contacts %>
	#
	def toolbar(options = {}, &block)
		if options[:option] && block_given?
			menu_options[options[:option]] = capture(&block)
		end

		content = capture do
			if options[:profile]
				render :partial => 'subjects/toolbar_profile', :locals => { :subject => options[:profile] }
			else
				render :partial => 'subjects/toolbar_home'
			end
		end

		case request.format
		when Mime::JS
			<<-EOJ
			  /*
		      $('#toolbar').html('#{ escape_javascript(content) }');
		      */
		      expandSubMenu('#{ options[:option] }');
		      EOJ
		else
			content_for(:toolbar) do
				content
			end
			content_for(:javascript) do
				<<-EOJ
				expandSubMenu('#{ options[:option] }');
				EOJ
			end
		end

	end

	# Cache menu options for toolbar
	#
	# @api private
	def menu_options #:nodoc:
		@menu_options ||= {}
	end
end

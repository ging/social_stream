class PlacesController < ApplicationController
  include SocialStream::Controllers::Objects

  before_filter :profile_subject!, :only => :index

  def show
    if (@place.latitude == 0 && @place.longitude == 0) 
      if @place.geocode
        @place.update_column(:latitude, @place.latitude)
        @place.update_column(:longitude, @place.longitude)
      end
    end
    show! do |format|
      format.html {
        @json = @place.to_gmaps4rails
      }
    end
  end


  def create
    params[:place].merge!(:owner_id => current_subject.try(:actor_id), :relation_ids => Relation::Public.instance.id,
    	:author_id => current_subject.try(:actor_id), :user_author_id => current_user.id)
    @place = Place.new(place_params)
    create!
  end

  private
    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def place_params
      params.require(:place).permit(:title, :latitude, :longitude, :phone_number, :url, :owner_id, :relation_ids, :author_id, :user_author_id, address_attributes: [:streetAddress, :postalCode, :locality, :region, :country])
    end
end

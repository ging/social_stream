class ActivityObjectProperty < ActiveRecord::Base
  belongs_to :activity_object,
             inverse_of: :activity_object_properties

  belongs_to :property,
             class_name: "ActivityObject",
             inverse_of: :activity_object_holds

  before_create :set_main
  after_update :update_main

  scope :main, where(main: true)

  def siblings
    self.
      class.
      includes(:property).
      where(activity_object_id: activity_object_id).
      where("property_id != ?", property_id).
      merge(ActivityObject.where(object_type: property.object_type))
  end

  private

  # before_create callback
  def set_main
    if !main? && siblings.blank?
      self.main = true
    elsif main? && siblings.present?
      remove_main_from_siblings
    end
  end

  # after_update callback
  def update_main
    remove_main_from_siblings if main?
  end

  def remove_main_from_siblings
    siblings.main.each do |s|
      s.update_attribute :main, false
    end
  end
end

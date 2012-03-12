class CreateActorType < ActiveRecord::Migration
  def up
    add_column :actors, :type, :string

    Actor.reset_column_information
  end

  def down
    remove_column :actors, :type
  end
end

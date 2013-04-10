class MoveAvatars < ActiveRecord::Migration
  class AvatarMigration < ActiveRecord::Base
    self.table_name = 'avatars'

    has_attached_file :logo
  end

  class ActorMigration < ActiveRecord::Base
    self.table_name = 'actors'
    self.record_timestamps = false

    has_one :avatar,
            conditions: { active: true },
            class_name: "AvatarMigration",
            foreign_key: :actor_id
    
    has_attached_file :logo
  end

  def up
    add_attachment :actors, :logo

    ActorMigration.all.each do |a|
      next if a.avatar.blank? ||
        ! File.exists?(a.avatar.logo.path.gsub('/move_avatars/avatar_migrations/', '/avatars/'))

      %w( file_name file_size content_type updated_at ).each do |f|
        a.update_attribute "logo_#{ f }", a.avatar.send("logo_#{ f }")
      end

      old_path = a.avatar.logo.path.gsub('/move_avatars/avatar_migrations/', '/avatars/').gsub(/original\/.*/, '.')
      new_path = a.logo.path.gsub('/move_avatars/actor_migrations/', '/actors/').gsub(/\/original\/.*/, '')
      puts "Copy #{ old_path } to #{ new_path }"

      FileUtils.mkdir_p new_path
      FileUtils.cp_r old_path, new_path
    end

    drop_table :avatars
  end

  def down
    raise "Irreversible migration"
  end
end

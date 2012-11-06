class CreateSocialStreamPresence < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :connected,    :default => false
      t.string  :status,       :default => "available"
      t.boolean :chat_enabled, :default => true
    end
  end
end

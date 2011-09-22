class AddFileProcessingToDocument < ActiveRecord::Migration
    def self.up
      add_column :documents, :file_processing, :boolean
    end
    
    def self.down
      remove_column :documents, :file_processing
    end
end

class ReplaceAttachmentFuWithPaperclip < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_file_name, :string # Original filename
    add_column :users, :avatar_content_type, :string # Mime type
    add_column :users, :avatar_file_size, :integer # File size in bytes
    
    add_column :games, :icon_file_name, :string # Original filename
    add_column :games, :icon_content_type, :string # Mime type
    add_column :games, :icon_file_size, :integer # File size in bytes
    
    add_column :games, :flash_file_name, :string # Original filename
    add_column :games, :flash_content_type, :string # Mime type
    add_column :games, :flash_file_size, :integer # File size in bytes
    add_column :games, :width, :integer, :default => 0
    add_column :games, :height, :integer, :default => 0
    
    drop_table :avatars
    drop_table :flashes
    drop_table :icons
  end

  def self.down
  end
end

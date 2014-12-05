class AddScreenshotsToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :screenshot_file_name,    :string
    add_column :games, :screenshot_content_type, :string
    add_column :games, :screenshot_file_size,    :integer
    add_column :games, :screenshot_updated_at,   :datetime
  end

  def self.down
    remove_column :games, :avatar_file_name
    remove_column :games, :avatar_content_type
    remove_column :games, :avatar_file_size
    remove_column :games, :avatar_updated_at
  end
end

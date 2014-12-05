class AddTouchToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :touch_compatible, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :games, :touch_compatible
  end
end

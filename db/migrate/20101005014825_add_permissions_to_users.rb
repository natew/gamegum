class AddPermissionsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :permissions, :integer, :default => 0  # File size in bytes
  end

  def self.down
  end
end

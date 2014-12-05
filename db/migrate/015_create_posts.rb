class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :discussion, :user
      t.text :message
      t.boolean :active, :default => true
      t.timestamps
    end
    
    add_index(:posts, [:discussion_id, :user_id])
  end

  def self.down
    drop_table :posts
  end
end

class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.references :topic, :user
      t.string :title, :null => false
      t.text :message, :null => false
      t.integer :views, :default => 0
      t.boolean :locked, :sticky, :default => false
      t.timestamps
    end
    
    add_index(:discussions, [:topic_id, :user_id])
  end

  def self.down
    drop_table :discussions
  end
end

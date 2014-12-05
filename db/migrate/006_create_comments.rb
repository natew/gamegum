class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :message, :null => false      
      t.references :game, :user, :null => false
      t.timestamps
    end
    
    add_index(:comments, [:game_id, :user_id])
  end

  def self.down
    drop_table :comments
  end
end

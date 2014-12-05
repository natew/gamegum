class CreateGames < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table
    
    create_table :games do |t|
      t.string :title, :null => false
      t.string :screenshot
      t.integer :views, :rating_count, :null => false, :default => 0
      t.decimal :rating_total, :default => 0
      t.decimal :rating_avg, :precision => 10, :scale => 2, :default => 0
      t.boolean :featured, :active, :nudity, :violence, :language, :default => false
      t.text :description, :null => false
      t.references :user, :category, :null => false
      t.timestamp :featured_at
      t.timestamps
    end
    
    add_index(:games, [:user_id, :category_id, :title])
  end

  def self.down
    drop_table :games
    
    ActiveRecord::Base.drop_ratings_table
  end
end

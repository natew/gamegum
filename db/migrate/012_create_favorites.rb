class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.references :user, :game
    end
  end

  def self.down
    drop_table :favorites
  end
end

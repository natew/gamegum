class CreatePagesGames < ActiveRecord::Migration
  def self.up
    create_table :pages_games, :id => false do |t|
      t.references :page, :game
    end
  end

  def self.down
    drop_table :pages_games
  end
end

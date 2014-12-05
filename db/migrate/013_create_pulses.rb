class CreatePulses < ActiveRecord::Migration
  def self.up
    create_table :pulses do |t|
      t.string :category, :description
      t.integer :stars, :default => 0
      t.references :user, :game
      t.timestamps
    end
    
    add_index(:pulses, [:user_id, :game_id])
  end

  def self.down
    drop_table :pulses
  end
end

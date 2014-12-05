class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title, :icon
      t.text :description
      t.boolean :active, :default => true
    end
  end

  def self.down
    drop_table :topics
  end
end

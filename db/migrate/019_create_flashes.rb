class CreateFlashes < ActiveRecord::Migration
  def self.up
    create_table :flashes do |t|
      t.string :filename, :content_type, :type
      t.integer :height, :width, :size
      t.references :game, :null => false
    end
  end

  def self.down
    #drop_table :flashes
  end
end

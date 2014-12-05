class CreateIcons < ActiveRecord::Migration
  def self.up
    create_table :icons do |t|
      t.string :thumbnail, :filename, :content_type, :type
      t.integer :height, :width, :size
      t.references :game, :null => false
    end
  end

  def self.down
    #drop_table :icons
  end
end

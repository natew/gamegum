class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.string :thumbnail, :filename, :content_type
      t.integer :height, :width, :size
      t.references :user, :null => false
    end
  end

  def self.down
    #drop_table :avatars
  end
end

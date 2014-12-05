class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string    :title, :slug, :image_file_name, :image_file_size, :image_content_type
      t.text      :description
      t.integer   :views, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end

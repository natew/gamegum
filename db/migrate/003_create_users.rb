class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :login, :email, :null => false
      t.string    :crypted_password, :salt, :limit => 40
      t.string    :remember_token
      t.string    :location, :aim, :msn, :adsense, :website, :time_zone, :signature, :ip, :default => ''
      t.datetime  :remember_token_expires_at
      t.boolean   :email_confirmed, :active, :revenue_share, :banned, :default => false
      t.boolean   :show_avatar, :show_email, :default => true
      t.integer   :views, :gumpoints, :default => 0
      t.text      :about_me
      t.timestamp :age
      t.timestamps
    end
    
    add_index(:users, [:login])
  end

  def self.down
    drop_table :users
  end
end

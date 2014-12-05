class AddAdultOptionToTopicsAndPulse < ActiveRecord::Migration
  def self.up
    add_column :pages, :adult, :boolean, :null => false, :default => false
    add_column :pulses, :adult, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pages, :adult
    remove_column :pulses, :adult
  end
end

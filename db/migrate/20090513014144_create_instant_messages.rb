class CreateInstantMessages < ActiveRecord::Migration
  def self.up
    create_table :instant_messages do |t|
      t.integer  :user_id, :chat_id
      t.text     :message
      t.timestamps
    end
  end

  def self.down
    drop_table :instant_messages
  end
end

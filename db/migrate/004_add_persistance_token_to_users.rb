class AddPersistanceTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :persistance_token, :string
  end

  def self.down
    remove_column :users, :persistance_token
  end
end

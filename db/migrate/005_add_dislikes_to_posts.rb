class AddDislikesToPosts < ActiveRecord::Migration

  def self.up
    add_column :posts, :dislikes, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :dislikes
  end
end


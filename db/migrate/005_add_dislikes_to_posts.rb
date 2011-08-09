class AddDislikesToPosts < ActiveRecord::Migration

  def self.up
    add_column :posts, :dislikes, :integer
  end

  def self.down
    remove_column :posts, :dislikes
  end
end


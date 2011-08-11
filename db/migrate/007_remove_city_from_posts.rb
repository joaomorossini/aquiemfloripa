class RemoveCityFromPosts < ActiveRecord::Migration

  def self.up
    remove_column :posts, :city
  end

  def self.down
    add_column :posts, :city, :string
  end
end


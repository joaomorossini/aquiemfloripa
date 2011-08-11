class AddCityToPosts < ActiveRecord::Migration

  def self.up
    add_column :posts, :city, :string
  end

  def self.down
    remove_column :posts, :city
  end
end

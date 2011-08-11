class AddCityIdToPosts < ActiveRecord::Migration

  def self.up
    add_column :posts, :city_id, :integer
  end

  def self.down
    remove_column :posts, :city_id
  end
end

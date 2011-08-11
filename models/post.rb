class Post < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :city

  extend WillPaginate::Finders::Base
  
  scope :recent, order('created_at desc')
  scope :featured, order('likes-dislikes desc').where('created_at > ?', Time.new - 7.days)
  scope :city, lambda{|t| where(:city_id => t)}

end

class Post < ActiveRecord::Base
  belongs_to :user
  extend WillPaginate::Finders::Base
  scope :recent, order('created_at desc')
  scope :featured, order('likes-dislikes desc').where('created_at > ?', Time.new - 7.days)
end

# message (text)
# user_id (integer)
# created_at (datetime)
# updated_at (datetime)

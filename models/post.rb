class Post < ActiveRecord::Base
  belongs_to :user
end

# message (text)
# user_id (integer)
# created_at (datetime)
# updated_at (datetime)

class Like < ActiveRecord::Base
    belongs_to :user
    
    validates :like_id, uniqueness: { scope: [:user_id] }
    
end

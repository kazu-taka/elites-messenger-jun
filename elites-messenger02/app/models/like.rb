class Like < ActiveRecord::Base
    belongs_to :user
    belongs_to :timeline
    
    validates :timeline_id, uniqueness: { scope: [:user_id] }
    
end

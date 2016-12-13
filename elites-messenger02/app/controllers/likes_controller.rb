class LikesController < ApplicationController
    def create
        likes = Like.new
        likes.attributes = like_param
        likes.user_id = current_user.id
        if likes.valid?
            likes.save!
        else
            flash[:alert] = "エラーになりました"
        end
        redirect_to timelines_path
    end
    
    private
    def like_param
        params.permit(:like_id)
    end
    
end

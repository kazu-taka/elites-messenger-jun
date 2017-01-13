class LikesController < ApplicationController
    def create
        like = current_user.likes.build(like_param)
        # like = Like.new
        # likes.attributes = like_param
        # likes.user_id = current_user.id
        if like.valid?
            like.save!
        else
            flash[:alert] = "エラーになりました"
        end
        redirect_to timelines_path
    end
    
    private
    def like_param
        params.permit(:timeline_id)
    end
    
end

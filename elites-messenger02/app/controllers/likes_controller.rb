class LikesController < ApplicationController
    def create
        if likes.valid?
            likes.save!
        else
            flash[:alert] = "エラーになりました"
        end
        redirect_to timeline_path
    end
end

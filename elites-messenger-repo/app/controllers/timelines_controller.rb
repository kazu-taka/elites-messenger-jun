class TimelinesController < ApplicationController
  def index
    # メッセージ入力
    @input_message = Timeline.new
  end
end

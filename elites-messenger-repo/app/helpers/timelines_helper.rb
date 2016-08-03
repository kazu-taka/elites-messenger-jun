module TimelinesHelper

  # 自分の投稿か判定する
  def mypost?(timeline)
    timeline.user.id == current_user.id
  end

end

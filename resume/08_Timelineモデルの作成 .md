## Timelineモデルの作成

`rails g model`コマンドでTimelineモデルを作成
```
$ rails g model Timeline user_id:integer message:text
$ rake db:migrate
```

usersテーブルとアソシエーションを結ぶ
```
# app/models/timeline.rb

class Timeline < ActiveRecord::Base
  belongs_to :user
end
```

#### アソシエーションについての補足
todo

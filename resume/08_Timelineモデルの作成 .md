## Timelineモデルの作成

`rails g model`コマンドでTimelineモデルを作成する。

```
$ rails g model Timeline user_id:integer message:text

```

`rake db:migrate`でデータベースに反映する。

```
$ rake db:migrate
```

usersテーブルとアソシエーションを設定する。
```
# app/models/timeline.rb

class Timeline < ActiveRecord::Base
  belongs_to :user
end
```

#### アソシエーションについての補足
todo

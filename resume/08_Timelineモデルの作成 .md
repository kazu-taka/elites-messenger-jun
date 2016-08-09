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

#### 補足: アソシエーション

アソシエーションによって引数に単数形、複数形の違いがあることに注意。

アソシエーション名 | 単数形 or 複数形 | 例
-- | -- | --
belongs_to | 単数形 | belongs_to :user
has_many | 複数形 | has_many :users
has_one | 単数形 | has_one :user
has_and_belongs_to_many | 複数形 | has_and_belongs_to_many :users
has_many + through | 複数形 | has_many :users, through: :somethings

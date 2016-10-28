## Timelineモデルの作成

`rails g model`コマンドでTimelineモデルを作成します。

```bash
$ bundle exec rails g model Timeline user_id:integer message:text

```

`rake db:migrate`でデータベースに反映する。

```bash
$ bundle exec rake db:migrate
```

usersテーブルとアソシエーションを設定します。<br>
ライムラインは1人のユーザーと紐付いているため(誰が発言したか分かっているため)、`belongs_to`となります。
```ruby
# app/models/timeline.rb

class Timeline < ActiveRecord::Base
  belongs_to :user
end
```

<br>
### 補足: アソシエーション

アソシエーションによって引数に単数形、複数形の違いがあることに注意して下さい。<br>
現時点では`belongs_to`と`has_many`を理解していれば良いです。

|アソシエーション名 | 単数形 or 複数形 | 例|
|:--: | :--: | :--:|
|belongs_to | 単数形 | belongs_to :user|
|has_many | 複数形 | has_many :users|
|has_one | 単数形 | has_one :user|
|has_and_belongs_to_many | 複数形 | has_and_belongs_to_many :users|
|has_many + through | 複数形 | has_many :users, through: :somethings|

<br>
#### :bulb: `has_many`／`belongs_to`は双方必須か？
必要なアクセスだけあれば良いので、`Timeline.user.◯◯`のアクセスしかしないのであれば、`belongs_to`だけで構いません。<br>
`User.timelines`というアクセスも必要であれば、`has_many :timelines`も必要です。<br>
後々の利用を考慮すれば、最初から`belongs_to`と`has_many`を記述しておいたほうが良いです。

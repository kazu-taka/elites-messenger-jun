## Gemライブラリのインストール

以下のライブラリをインストールするため、Gemfileを記入し`bundle install`を行う。
- Devise
- CarrierWave
- Twitter-Bootsrap

```
# Gemfile

# 以下を追記
gem 'devise'
gem 'carrierwave'
gem 'twitter-bootstrap-rails'
```

```
$ bundle install
```

#### 補足: Gemfile11

Gemfileは以下のフォーマットで記入する
```

# 最近のライブラリをインストール
gem [ライブラリ名]

# バージョンを固定
gem [ライブラリ名], x.x.x

# x系の最新
gem [ライブラリ名], ~> x.0

# Gitのライブラリをインストール
gem [ライブラリ名], git: [URL]

# ローカルに保存しているライブラリをインストール
gem [ライブラリ名], path: [パス]

# 特定の環境でのみインストール
group [環境名] do
  gem [ライブラリ名]
end

```

#### 補足: bundle install と bundle exec

- `bundle install`したライブラリは「./vendor/bundle」のディレクトリに格納される。
- `bundle install`のライブラリを使用してコマンドを実行する場合はコマンドに`bundle exec`というプレフィックスを付ける必要がある。

```
# プレフィックス無し。GEM_PATHに格納された共通ライブラリを使用する。
$ rake ...

# プレフィックス有り。「./vendor/bundle」に格納されたプロジェクト用ライブラリを使用する。
$ bundle exec rake ...

```

- `bundle exec`無しではプロジェクトのライブラリとのバージョン不一致により`You have already activated ...`エラーが発生する可能性があるため、プロジェクト内で使用するRailsコマンドには`bundle exec`をつけた方が無難。

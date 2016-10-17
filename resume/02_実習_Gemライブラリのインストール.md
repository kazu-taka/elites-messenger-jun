## Gemライブラリのインストール

以下のライブラリをインストールするため、`Gemfile`に記入し`bundle install`を行います。
- Devise<br>
  ログイン認証機能
- CarrierWave<br>
  ファイルアップロード機能
- Twitter-Bootstrap<br>
  RailsアプリにBootstrapを適用

```ruby
# Gemfile

source 'https://rubygems.org'

#--***************************省略*****************************--

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

#--************************ 下記を追加 ***************************
gem 'devise'

gem 'carrierwave'

gem 'twitter-bootstrap-rails'
#--**************************************************************

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

#--***************************省略*****************************--

```

`Gemfile`を修正したら`bundle install`を実行します。

```bash
$ bundle install
```

<br>
### 補足: Gemfile

Gemfileは以下のフォーマットで記入します。

```ruby

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

### 補足: bundle install と bundle exec

- `bundle install`したライブラリは「./vendor/bundle」のディレクトリに格納されます。
- `bundle install`のライブラリを使用してコマンドを実行する場合はコマンドに`bundle exec`というプレフィックスを付ける必要があります。

```
# プレフィックス無し。GEM_PATHに格納された共通ライブラリを使用します。
$ rake ...

# プレフィックス有り。「./vendor/bundle」に格納されたプロジェクト用ライブラリを使用します。
$ bundle exec rake ...

```
<br>
ターミナルで下記のコマンドを入力すると`GEM_PATH`を確認することが可能です。
```bash
$ gem environment
```
`bundle exec`無しではプロジェクトのライブラリとのバージョン不一致により`You have already activated ...`エラーが発生する可能性があるため、プロジェクト内で使用するRailsコマンドには`bundle exec`をつけた方が無難です。

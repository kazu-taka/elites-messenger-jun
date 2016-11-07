## Userモデルの作成

### deviseのファイル設定と作成

deviseのコマンドを使用し、設定ファイルとビューを生成します。
```bash
$ bundle exec rails g devise:install
$ bundle exec rails g devise:views
```

<br>
### Userモデルの作成

`devise`のコマンドで`User`を作成します。
```bash
$ bundle exec rails g devise User
```
<br>
### Userモデルにname, thumbnail, agreementを追加

自動生成されたマイグレーションスクリプトにカラムを追加します。<br>
`rake db:migrate`を実行するとデータベースに反映されてしまうので、`rake db:migrate`を実行する前に追加します。<br>

```ruby
# db/migrate/(日付)_devise_create_users.rb

class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

#--*********************** 下記を追加 ************************
      t.string :name, null: false
      t.string :thumbnail
      t.boolean :agreement, null: false
#--**********************************************************

#--************************** 省略 **************************

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
```

<br>
`rake db:migrate`コマンドでデータベースに反映する。
```bash
$ bundle exec rake db:migrate
```

<br>
StrongParameters機能により、ユーザ新規作成の入力項目はデフォルトで認証に必要なキー(email)とパスワードとパスワード確認のみ許可されています。<br>
StrongParametersにname、thumbnail、agreementを含むように`application_controller.rb`を編集します。<br>
`keys:`を使用すると、複数の項目を指定することが可能です。

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # deviseのコントローラを実行する時は「configure_permitted_parameters」メソッドを実行する
#--**************************** 下記を追加 ****************************
  before_action :configure_permitted_parameters, if: :devise_controller?

  private
  def configure_permitted_parameters
    # 新規作成にname、thumbnail、agreementパラメータを含める
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :thumbnail, :agreement])
  end
#--*******************************************************************

end
```

<br>
### carrierwaveによるユーザサムネイル用アップローダー作成

carrierwaveの`rails g uploader`コマンドでサムネイル用アップローダー管理ファイルを作成します。<br>
（carrierwaveのアップロード用設定を定義した`Uploader`クラスが`app/uploaders` ディレクトリ以下に生成されます）

```bash
$ bundle exec rails g uploader UserThumbnail
```

下記のようなファイルが生成されます。
```ruby
# app/uploaders/user_thumbnail_uploader.rb

# encoding: utf-8

class UserThumbnailUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
#--********************* 省略 **********************

end

```

`User`モデルの`thumbnail`と作成した管理ファイルを紐付けます。
```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

#--************************** 下記を追加 *************************
  # サムネイル画像にCarrierWaveで作成したUserThumbnailUploaderを使用
  mount_uploader :thumbnail, UserThumbnailUploader
#--***************************************************************
end

```

<br>
### Carrierwaveの`uninitialized constant`エラー
稀にRailsコマンド実行時`UserThumbnailUploader`が見つからずに`uninitialized constant`エラーが発生する場合があります。<br>
頻繁に発生する場合は`config/application.rb`に`autoload_paths`のパス追加を記入します。<br>
ファイルを修正した後は、サーバを再起動します。

```ruby
# config/application.rb

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Messenger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

#--************************** 省略 ***************************

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
#--**************************** 下記を追加 ***************************
    config.autoload_paths += Dir[Rails.root.join('app', 'uploaders')]
#--*******************************************************************
  end
end
```

`Dir[Rails.root.join('app', 'uploaders')]`がどのような動きをしているか確認したい場合は、`rails c`でコンソールを立ち上げます。
```bash
~/workspace/elites-messenger20 (master) $ rails c
```

プログラムを分解して実行する事も可能です。
```bash
2.3.0 :001 > Rails.root
 => #<Pathname:/home/ubuntu/workspace/elites-messenger/src> 
2.3.0 :002 > Rails.root.join('app', 'uploaders')
 => #<Pathname:/home/ubuntu/workspace/elites-messenger/src/app/uploaders> 
2.3.0 :003 > Dir[Rails.root.join('app', 'uploaders')]
 => ["/home/ubuntu/workspace/elites-messenger/src/app/uploaders"] 
```

<br>
### 補足: コントローラのフィルタ機能

- アクションの前後に処理を追加する場合は`before_action`、`after_action`フィルタを使用します。  
- 主に認証の判定やログ出力などに利用されます。
- 設定したフィルタを無効化したい場合は`skip_before_action`、`skip_after_action`フィルタを使用します。

<br>
### 補足: carrierwave

- carrierwaveは画像アップロード機能を簡単にするためのGemライブラリです。  
- `rails g uploader`コマンドでアップローダー管理ファイルが`app/uploaders`ディレクトリに作成されます。
- 動作の設定には管理ファイルを編集します。

よく編集するメソッド
- `store_dir` ・・・ 画像を保存するパス
- `extension_white_list` ・・・ 保存を許可する画像の拡張子

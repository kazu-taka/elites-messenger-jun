## Userモデルの作成

### deviseのファイル設定と作成

deviseのコマンドを使用し、設定ファイルとビューを生成する。
```
$ bundle exec rails g devise:install
$ bundle exec rails g devise:views
```

パスワードリマインダー用にメール設定を行う。
```
# config/envirnments/development.rb

# 以下を追記
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

```

### Userモデルの作成

deviseのコマンドでUserを作成する。
```
$ bundle exec rails g devise User
```

### Userモデルにname, thumbnail, agreementを追加

自動生成されたmigrateファイルにカラムを追加する。

```
# db/migrate/(日付)_devise_create_users.rb

class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # 以下を追記
      t.string :name, null: false
      t.string :thumbnail
      t.boolean :agreement, null: false

    **省略**

  end
end
```


`rake db:migrate`コマンドでデータベースに反映する。
```
$ bundle exec rake db:migrate
```

StrongParameters機能により、ユーザ新規作成の入力項目はデフォルトで認証に必要なキー(email)とパスワードとパスワード確認のみ許可されている。  
StrongParametersにname、thumbnail、agreementを含むように`application_controller.rb`を編集する。
```
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # deviseのコントローラを実行する時は「configure_permitted_parameters」メソッドを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  private
  def configure_permitted_parameters
    # 新規作成にname、thumbnail、agreementパラメータを含める
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :thumbnail, :agreement])
  end
end

```

### carrierwaveによるユーザサムネイル用アップローダー作成

carrierwaveの`g uploader`コマンドでサムネイル用アップローダー管理ファイルを作成する。
```
$ bundle exec rails g uploader UserThumbnail
```

thumbnailと作成した管理ファイルを紐付ける。
```
# app/models/user.rb

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # サムネイル画像にCarrierWaveで作成したUserThumbnailUploaderを使用
  mount_uploader :thumbnail, UserThumbnailUploader
end

```

#### 補足: コントローラのフィルタ機能

- アクションの前後に処理を追加する場合は`before_action`、`after_action`フィルタを使用する。  
- 主に認証の判定やログ出力などに利用される。
- 設定したフィルタを無効化したい場合は`skip_before_action`、`skip_after_action`フィルタを使用する。

#### 補足: carrierwave

- carrierwaveは画像アップロード機能を簡単にするためのGemライブラリ。  
- `rails g uploader`コマンドでアップローダー管理ファイルが`app/uploaders`ディレクトリに作成される。
- 動作の設定には管理ファイルを編集する。

よく編集するメソッド
- `store_dir` ・・・ 画像を保存するパス
- `extension_white_list` ・・・ 保存を許可する画像の拡張子

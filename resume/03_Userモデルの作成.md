## Userモデルの作成

### deviseのファイル設定と作成

deviseコマンドで設定ファイルと画面を生成する。
```
$ rails g devise:install
$ rails g devise:views
```

パスワードリマインダー用にメール設定を行う。
```
# config/envirnments/development.rb

# 以下を追記
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

```

### Userモデルの作成

deviseのコマンドで作成。
```
$ rails g devise User
```

### Userモデルにname, thumbnail, agreementを追加

migrateファイルに追加。
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

データベースに反映
```
$ rake db:migrate
```

#### 「bundle exec」 の補足
todo

新規作成時に追加したパラメータを参照するように設定。
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
    # 新規作成する場合にname、thumbnail、agreementパラメータを含める
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :thumbnail, :agreement])
  end
end

```

CarrierWaveのコマンドでサムネイル用にアップローダーを作成し、thumbnailとアップローダーを紐付ける。
```
$  rails g uploader UserThumbnail
```
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

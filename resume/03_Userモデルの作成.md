## Userモデルの作成

### deviseのファイル設定と作成

deviseのコマンドを使用し、設定ファイルと画面を生成する。
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

deviseのコマンドでUserを作成する。
```
$ rails g devise User
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
$ rake db:migrate
```

#### 「bundle exec」 の補足
todo

ユーザ新規作成の入力項目にname、thumbnail、agreementを含むように`application_controller.rb`に設定。
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

#### before_actionの補足
todo


CarrierWaveのコマンドでサムネイル用アップローダーを作成する。
```
$  rails g uploader UserThumbnail
```

thumbnailと作成したアップローダーを紐付ける。
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

#### CarrierWaveの補足
todo

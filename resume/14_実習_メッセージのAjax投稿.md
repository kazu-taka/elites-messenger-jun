## メッセージのAjax投稿

`create`アクションを編集し、JSONリクエストであれば結果をJSONで返却するように変更します。

```diff
# app/controllers/timeline_controller.rb

class TimelinesController < ApplicationController

#--****************** 省略 *********************

  def create
    timeline = Timeline.new
    timeline.attributes = input_message_param
    timeline.user_id = current_user.id
    if timeline.valid? # バリデーションチェック
      timeline.save!
    else
      flash[:alert] = timeline.errors.full_messages
    end
-    redirect_to action: :index
+    unless request.format.json?
+      redirect_to action: :index
+    else
+      # ajaxの場合のレスポンス
+      html = render_to_string partial: 'timelines/timeline', layout: false, formats: :html, locals: { t: timeline }
+      render json: {timeline: html}
+    end
  end

#--*********************** 省略 *******************
end
```

:bulb:render_to_string<br>
`render_to_string` メソッドは、テンプレート (erbファイル) のパース結果を strng として受け取るメソッドです。<br>
この場合は、`app/views/timelines/timeline.html.erb` のレンダリング内容を `html` に string として代入します。

タイムライン画面を編集します。
- Ajax投稿用のボタンを追加
- `form_for`にオプションを指定
  - 非同期通信のオプションの`remote: true`を設定
  - `html`オプションを使用して、`input_message_form`というclassを指定(`class`オプションを使用しても良い)
  - ajaxを使用してjson形式で結果を受け取るため、`format: :json`を指定
  - `remote: true`にした場合、`authenticity_token`が埋め込まれないので、指定する必要がある
  
:bulb:非同期通信<br>
送信者のデータ送信タイミングと受信者のデータ受信タイミングを合わせずに通信を行う通信方式です。
<br><br>
:bulb:authenticity_token<br>
CSRF(Cross-Site Request Forgeries)を防止する目的で設置されたRailsの機能です。<br>
CSRFとはWebアプリケーションに存在する脆弱性、もしくはその脆弱性を利用した攻撃方法のことを指します。

```diff
# app/views/timelines/index.html.erb

<div class="wrapper timeline_wrapper">

  <!-- メッセージ入力 -->
  <div class="input">
    
-    <%= form_for @input_message do |f| %>
+    <%= form_for @input_message, remote: true, html: {class: 'input_message_form'}, format: :json, authenticity_token: true do |f| %>

      <div class="form-group">
        <%= f.label :message %>
        <% if @input_message.persisted? %>
          編集中
        <% elsif @reply_timeline %>
          <%= @reply_timeline.user.name %>の「<%= truncate(@reply_timeline.message, length: 7) %>」に返信
        <% end %>
        <br/>
        <%= f.text_area :message, class: 'form-control', row: 3 %>
      </div>
      <div class="actions clearfix">
        <div class="alert">
          <p class="alert"><%= alert %></p>
        </div>
        <div class="post">
          <% if @input_message.persisted? || @reply_timeline %>
            <%= link_to root_path do %>
              <%= button_tag 'Cancel', class: 'btn btn-default' %>
            <% end %>
          <% end %>
-          <%= f.submit 'Post', class: 'btn btn-primary' %>
+          <%= f.submit 'Post', class: 'btn btn-primary post' %>
+          <%= f.submit 'AjaxPost', class: 'btn btn-primary ajaxpost' %>
        </div>
      </div>

      <%= f.hidden_field :reply_id, value: @reply_timeline.id if @reply_timeline %>
    <% end %>
  </div>

  <div class="user_filter">
    <%= form_tag filter_by_user_timelines_path do |f| %>
        <div class="form-group">
          <label>ユーザフィルター</label><br/>
          <%= select_tag :filter_user_id, options_for_select(@users.map { |m| [m.name, m.id] }, params[:filter_user_id]), prompt: 'フィルターなし', class: 'form-control' %>
        </div>
        <div class="actions">
          <%= submit_tag 'Apply', class: 'btn btn-primary' %>
        </div>
    <% end %>
  </div>

  <!-- タイムライン -->
  <div class="timeline">
    <% @timeline.each do |t| %>
        <%= render 'timelines/timeline', t: t %>
    <% end %>
  </div>

</div>
```

タイムライン用のJavaScript処理を作成します。
- `timelines.coffee`のファイル名を`timelines.js`に変更
- `create`アクションのレスポンス処理を追加
- `form_for`のAjax投稿でない方の投稿ボタンは非同期通信にしない

Javascriptで書く場合
```JavaScript
# app/assets/javascripts/timelines.js

$(function(){
  $('form.input_message_form input.post').click(function(e){
    // 「Post」ボタンは非Ajaxにする
    var form = $('form.input_message_form');
    form.removeAttr('data-remote');
    form.removeData("remote");
    form.attr('action', form.attr('action').replace('.json', ''));
  });

  $('form.input_message_form').on('ajax:complete', function(event, data, status){
    // Ajaxレスポンス
    if ( status == 'success') {
      var json = JSON.parse(data.responseText);
      $('div.timeline').prepend($(json.timeline));
    }
  });
});
```

### 動作確認
- Ajax投稿ボタンで画面遷移なしでメッセージが投稿されること。

### 補足: 非同期通信
- 非同期通信をする場合は`link_to`、`form_tag`、`form_for`タグにたいして`remote: true`オプションを付ける。
- 通信のレスポンスは`$('remoteを設定したタグ').on('ajax:success', ... )`のフォーマット受け取る。

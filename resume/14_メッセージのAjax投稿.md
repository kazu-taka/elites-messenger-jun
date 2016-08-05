## メッセージのAjax投稿

`create`アクションを編集し、JSONリクエストであれば結果をJSONで返却するように変更。

```
# app/controllers/timeline_controller.rb

class TimelinesController < ApplicationController
  def index
    # メッセージ入力
    @input_message = params[:id] ? Timeline.find(params[:id]) : Timeline.new
    # タイムラインを取得
    @timeline = Timeline.includes(:user).not_reply.user_filter(params[:filter_user_id]).order('updated_at DESC')
    # ユーザ一覧を取得
    @users = User.all

    if params[:reply_id]
      # 返信時は返信のタイムライン情報を取得
      @reply_timeline = Timeline.find(params[:reply_id])
    end

  end

  def create
    timeline = Timeline.new
    timeline.attributes = input_message_param
    timeline.user_id = current_user.id
    if timeline.valid? # バリデーションチェック
      timeline.save!
    else
      flash[:alert] = timeline.errors.full_messages
    end
    unless request.format.json?
      redirect_to action: :index
    else
      # ajaxの場合のレスポンス
      html = render_to_string partial: 'timelines/timeline', layout: false, formats: :html, locals: { t: timeline }
      render json: {timeline: html}
    end
  end

  def update
    timeline = Timeline.find(params[:id])
    timeline.attributes = input_message_param
    if timeline.valid? # バリデーションチェック
      timeline.save!
    else
      flash[:alert] = timeline.errors.full_messages
    end
    redirect_to action: :index
  end

  def destroy
    timeline = Timeline.find(params[:id])
    timeline.destroy
    redirect_to action: :index
  end

  def filter_by_user
    if params[:filter_user_id].present?
      redirect_to action: :index, filter_user_id: params[:filter_user_id]
    else
      # フィルターなし
      redirect_to action: :index
    end
  end

  private
  def input_message_param
    params.require(:timeline).permit(:message, :reply_id)
  end

end
```


Timeline画面を編集。
- Ajax投稿用のボタンを追加
- `form_for`に非同期通信のオプションを設定

```
# app/views/timelines/index.html.erb

<div class="wrapper timeline_wrapper">

  <!-- メッセージ入力 -->
  <div class="input">
    <%= form_for @input_message, remote: true, html: {class: 'input_message_form'}, format: :json, authenticity_token: true do |f| %>
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
            <%= f.submit 'Post', class: 'btn btn-primary post' %>
            <%= f.submit 'AjaxPost', class: 'btn btn-primary ajaxpost' %>
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

- `create`アクションのレスポンス処理を追加
- `form_for`のAjax投稿でない方の投稿ボタンは非同期通信にしない

```
# app/assets/javascripts/timelines.coffee

$ ->
  initPostButtonEvent = ->
    $('form.input_message_form input.post').click((e) =>
      # 「Post」ボタンは非Ajaxにする
      form = $('form.input_message_form')
      form.removeAttr('data-remote')
      form.removeData("remote")
      form.attr('action', form.attr('action').replace('.json', ''))
    )
  initPostButtonEvent()
  $('form.input_message_form').on('ajax:complete', (event, data, status) ->
    # Ajaxレスポンス
    if status == 'success'
      json = JSON.parse(data.responseText)
      $('div.timeline').prepend($(json.timeline))
      initPostButtonEvent()
  )
```

#### 非同期通信の補足

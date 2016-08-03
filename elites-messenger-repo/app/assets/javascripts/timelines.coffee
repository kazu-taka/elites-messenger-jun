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
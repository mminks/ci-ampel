module Utilities
  def set_slack_hook_uri
    ENV['SLACK_HOOK_URI'] ? ENV['SLACK_HOOK_URI'] : ''
  end

  def set_slack_channel
    ENV['SLACK_CHANNEL'] ? ENV['SLACK_CHANNEL'] : '#ampel'
  end

  def cpluralize(number, text)
    return text.pluralize if number != 1
    return text.singularize if number == 1
  end

  def send_slack_message(message)
    if @slack && message
      RestClient.post(
        set_slack_hook_uri,
        { 'channel' => set_slack_channel, 'text' => message, 'username' => 'ci-ampel' }.to_json,
        { content_type: :json, accept: :json }
      )
    end
  end
end

module Utilities
  def set_slack_hook_uri
    ENV['SLACK_HOOK_URI'] ? ENV['SLACK_HOOK_URI'] : ''
  end

  def cpluralize(number, text)
    return text.pluralize if number != 1
    return text.singularize if number == 1
  end

  def send_slack_message(message)
    if @slack
      channel = "#ampel"
      slack_state_file = ".slack_state"

      if File.exists?(slack_state_file)
        unless File.read(slack_state_file) == message
          RestClient.post(
            set_slack_hook_uri,
            {'channel' => channel, 'text' => message}.to_json,
            {content_type: :json, accept: :json}
          )
        end
      end

      File.write(slack_state_file, message)
    end
  end
end

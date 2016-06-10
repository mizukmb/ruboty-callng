require 'twilio-ruby'
require 'uri'

module Ruboty
  module Call
    module Actions
      class Call < Ruboty::Actions::Base
        def call
          phone_call(generate_text)
        end

        def call_with_message
          phone_call(message[:text])
        end

        private

        def from
          ENV['RUBOTY_PHONE_NUMBER']
        end

        def language
          ENV['RUBOTY_LANG'] || 'ja-JP'
        end

        def generate_text
          channel = message.original[:channel] ? "at #{message.original[:channel]['name']} channel" : ''
          "#{message.original[:user]['name']} calls you #{channel} in Slack. Please open Slack"
        end

        def phone_call(text)
          twilio_client.account.calls.create({
            :to => to,
            :from => from,
            :url => twiml_url(text),
            :method => 'GET',
            :fallback_method => 'GET',
            :status_callback_method => 'GET',
          })
          message.reply("電話します")
        rescue => err
          message.reply("なにかに失敗したよ. #{err}")
        end

        def to
          message[:to]
        end

        def twilio_client
          # put your own credentials here
          account_sid = ENV['TWILIO_ACCOUNT_SID']
          auth_token = ENV['TWILIO_AUTH_TOKEN']

          Twilio::REST::Client.new account_sid, auth_token
        end

        def twiml(text)
          <<TWIML
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="alice" language="#{language}">#{text}</Say>
</Response>
TWIML
        end

        def twiml_url(text)
          "http://twimlets.com/echo?Twiml=#{URI.escape(twiml(text))}"
        end
      end
    end
  end
end

require "dotenv"
Dotenv.load(".env")

require "http/client"
require "json"

require "discordcr"

client = Discord::Client.new(token: ENV["TOKEN"], client_id: ENV["APPID"].to_u64)


def get(link : String)
  res = HTTP::Client.get link
  JSON.parse(res.body)
end

PREFIX = "."
USER = "<@249907655261290497> "
NICK = "<@!249907655261290497 "

client.on_message_create do |message|
  content = message.content
  if content.starts_with?(PREFIX)
    content = content[1..-1]
  elsif content.starts_with?(USER)
    content = content[USER.size..-1]
  elsif content.starts_with?(NICK)
    content = content[NICK.size..-1]
  else
    next
  end
  
  case content
  when .starts_with?("gif")
    msg = content.split
    tag = msg[1..-1].join("+")
    response = get "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=#{tag}"

    client.create_message(message.channel_id, "#{response["data"]["image_original_url"]}")
  when "help"
    client.create_message(message.channel_id, "responds with a random gif on `.gif [topic]`")
  when "invite"
    client.create_message(message.channel_id, "https://discordapp.com/oauth2/authorize?&client_id=249907655261290497&scope=bot")
  end
end

client.run

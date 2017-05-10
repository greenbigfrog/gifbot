require "ctx"
require "dotenv"

Dotenv.load(".env")

client = Ctx::Bot.new(token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"].to_u64)

# Obtains a gif from Giphy's API.
def gif(tag : String, key : String = ENV["GIPHY_API_KEY"])
  url = "https://api.giphy.com/v1/gifs/random?api_key=#{key}&tag=#{tag}"

  response = HTTP::Client.get url
  JSON.parse(response.body)["data"]["image_original_url"].as_s
end

# Macro for replying to an event.
macro reply(content, embed)
  client.create_message(payload.channel_id, {{content}}, {{embed}})
end

gif_ctx = Ctx::Context.message_create do |message|
  /^.gif|<@!?#{ENV["CLIENT_ID"]}>/.match(message.content).nil?
end

client.message_create(gif_ctx) do |payload|
  embed = Discord::Embed.new(
    image: Discord::EmbedImage.new(url: gif(payload.content))
  )

  reply nil, embed
end

client.command(".help") do |payload|
  reply "`.gif [topic]`", nil
end

client.command(".invite") do |payload|
  reply "https://discordapp.com/oauth2/authorize?&client_id=#{ENV["CLIENT_ID"]}&scope=bot", nil
end

client.run

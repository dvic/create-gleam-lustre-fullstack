import gleam/dynamic/decode
import gleam/json

pub type Message {
  Message(content: String)
}

pub fn message_decoder() -> decode.Decoder(Message) {
  use content <- decode.field("content", decode.string)
  decode.success(Message(content:))
}

pub fn message_to_json(message: Message) -> json.Json {
  let Message(content:) = message
  json.object([#("content", json.string(content))])
}

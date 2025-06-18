import gleam/http/response.{type Response}
import gleam/json
import gleam/option.{type Option}
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import plinth/browser/document
import plinth/browser/element as plinth_element
import rsvp
import shared.{type Message, Message}

pub fn main() {
  let initial_message =
    document.query_selector("#model")
    |> result.map(plinth_element.inner_text)
    |> result.then(fn(json) {
      json.parse(json, shared.message_decoder())
      |> result.replace_error(Nil)
    })
    |> result.unwrap(Message(""))

  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", initial_message)

  Nil
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    current_message: Message,
    input_text: String,
    saving: Bool,
    error: Option(String),
  )
}

fn init(message: Message) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      current_message: message,
      input_text: "",
      saving: False,
      error: option.None,
    )

  #(model, effect.none())
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ServerSavedMessage(Result(Response(String), rsvp.Error))
  UserTypedMessage(String)
  UserSavedMessage
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ServerSavedMessage(Ok(_)) -> #(
      Model(
        current_message: Message(model.input_text),
        input_text: "",
        saving: False,
        error: option.None,
      ),
      effect.none(),
    )

    ServerSavedMessage(Error(_)) -> #(
      Model(
        ..model,
        saving: False,
        error: option.Some("Failed to save message"),
      ),
      effect.none(),
    )

    UserTypedMessage(text) -> #(Model(..model, input_text: text), effect.none())

    UserSavedMessage -> #(
      Model(..model, saving: True),
      save_message(model.input_text),
    )
  }
}

fn save_message(text: String) -> Effect(Msg) {
  let body = shared.message_to_json(Message(text))
  let url = "/api/message"

  rsvp.post(url, body, rsvp.expect_ok_response(ServerSavedMessage))
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("min-h-screen bg-gray-50 py-8")], [
    html.div(
      [attribute.class("max-w-md mx-auto bg-white rounded-lg shadow-md p-6")],
      [
        html.h1(
          [attribute.class("text-2xl font-bold text-gray-900 mb-6 text-center")],
          [html.text("Message App")],
        ),
        // Current message display
        html.div([attribute.class("mb-6")], [
          html.h2([attribute.class("text-sm font-medium text-gray-700 mb-2")], [
            html.text("Current Message:"),
          ]),
          html.div(
            [attribute.class("p-3 bg-gray-100 rounded border text-gray-800")],
            [
              html.text(case model.current_message {
                Message("") -> "No message saved yet."
                Message(content) -> content
              }),
            ],
          ),
        ]),
        // Input form
        html.div([attribute.class("space-y-4")], [
          html.input([
            attribute.class(
              "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
            ),
            attribute.placeholder("Enter your message..."),
            attribute.value(model.input_text),
            event.on_input(UserTypedMessage),
          ]),
          html.button(
            [
              attribute.class(
                "w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed",
              ),
              event.on_click(UserSavedMessage),
              attribute.disabled(model.saving || model.input_text == ""),
            ],
            [
              html.text(case model.saving {
                True -> "Saving..."
                False -> "Save Message"
              }),
            ],
          ),
        ]),
        // Error display
        case model.error {
          option.None -> element.none()
          option.Some(error) ->
            html.div(
              [
                attribute.class(
                  "mt-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded",
                ),
              ],
              [html.text(error)],
            )
        },
      ],
    ),
  ])
}

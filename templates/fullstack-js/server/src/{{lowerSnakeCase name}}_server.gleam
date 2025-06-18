import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
import gleam/string
import gleam/string_tree
import mist
import simplifile
import wisp.{type Request, type Response}
import wisp/wisp_mist

import manifest.{type ManifestAssets}
import shared.{type Message, Message}

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  // Set up message file path
  let _ = simplifile.create_directory("./data")
  let message_file = "./data/message.txt"

  let assert Ok(priv_directory) = wisp.priv_directory("{{lowerSnakeCase name}}_server")
  let static_directory = priv_directory <> "/static"

  // Read the template
  let template_path = priv_directory <> "/.templates/index.html"
  let assert Ok(template) = simplifile.read(template_path)

  // Read the manifest file
  let manifest_path = static_directory <> "/.vite/manifest.json"
  let manifest_assets = case simplifile.read(manifest_path) {
    Ok(content) -> manifest.parse_manifest(content)
    Error(_) ->
      manifest.ManifestAssets(js_files: ["main.js"], css_files: ["main.css"])
  }

  let assert Ok(_) =
    handle_request(message_file, static_directory, template, manifest_assets, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

// REQUEST HANDLERS ------------------------------------------------------------

fn app_middleware(
  req: Request,
  static_directory: String,
  next: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: static_directory)

  next(req)
}

fn handle_request(
  message_file: String,
  static_directory: String,
  template: String,
  manifest_assets: ManifestAssets,
  req: Request,
) -> Response {
  use req <- app_middleware(req, static_directory)

  case req.method, wisp.path_segments(req) {
    // API endpoint for saving message
    Post, ["api", "message"] -> handle_save_message(message_file, req)

    // Everything else gets our HTML with hydration data
    Get, _ -> serve_index(message_file, template, manifest_assets)

    // Fallback for other methods/paths
    _, _ -> wisp.not_found()
  }
}

fn serve_index(
  message_file: String,
  template: String,
  manifest_assets: ManifestAssets,
) -> Response {
  // Fetch current message from file
  let current_message = load_message_from_file(message_file)

  // Build CSS links
  let css_links =
    manifest_assets.css_files
    |> list.map(fn(css) {
      "<link rel=\"stylesheet\" href=\"/static/" <> css <> "\">"
    })
    |> string.join("\n    ")

  // Build JS script tags
  let js_scripts =
    manifest_assets.js_files
    |> list.map(fn(js) {
      "<script type=\"module\" src=\"/static/" <> js <> "\"></script>"
    })
    |> string.join("\n    ")

  let head_content =
    css_links
    <> "\n    "
    <> js_scripts
    <> "\n    "
    <> "<script type=\"application/json\" id=\"model\">"
    <> json.to_string(shared.message_to_json(current_message))
    <> "</script>\n  "

  // Replace </head> with our content + </head>
  let html = string.replace(template, "</head>", head_content <> "</head>")

  wisp.html_response(string_tree.from_string(html), 200)
}

fn handle_save_message(message_file: String, req: Request) -> Response {
  // Add 1 second delay
  process.sleep(1000)

  use json <- wisp.require_json(req)

  case decode.run(json, shared.message_decoder()) {
    Ok(msg) -> {
      let Message(content) = msg
      // Return 500 error if message contains "oops"
      case string.contains(content, "oops") {
        True -> {
          wisp.internal_server_error()
        }
        False ->
          case save_message_to_file(message_file, msg) {
            Ok(_) -> {
              let body = wisp.Text(string_tree.from_string(msg.content))
              wisp.set_body(wisp.ok(), body)
            }
            Error(_) -> wisp.internal_server_error()
          }
      }
    }
    Error(_) -> wisp.bad_request()
  }
}

// FILE STORAGE ----------------------------------------------------------------

fn load_message_from_file(file_path: String) -> Message {
  case simplifile.read(file_path) {
    Ok(content) -> Message(content)
    Error(_) -> Message("")
  }
}

fn save_message_to_file(
  file_path: String,
  msg: Message,
) -> Result(Nil, simplifile.FileError) {
  let Message(content) = msg
  simplifile.write(file_path, content)
}

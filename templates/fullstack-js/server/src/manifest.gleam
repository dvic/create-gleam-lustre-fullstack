import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/string

pub type ManifestAssets {
  ManifestAssets(js_files: List(String), css_files: List(String))
}

type ManifestEntry {
  ManifestEntry(file: String, css: List(String), is_entry: Bool)
}

pub fn parse_manifest(json_string: String) -> ManifestAssets {
  let entry_decoder = {
    use file <- decode.field("file", decode.string)
    use css <- decode.field("css", decode.optional(decode.list(decode.string)))
    use is_entry <- decode.field("isEntry", decode.optional(decode.bool))
    decode.success(ManifestEntry(
      file: file,
      css: option.unwrap(css, []),
      is_entry: option.unwrap(is_entry, False),
    ))
  }

  let manifest_decoder = decode.dict(decode.string, entry_decoder)

  case json.parse(json_string, manifest_decoder) {
    Ok(manifest_dict) -> {
      // Use list.fold to accumulate JS and CSS files from all entries
      dict.values(manifest_dict)
      |> list.filter(fn(entry) { entry.is_entry })
      |> list.fold(ManifestAssets(js_files: [], css_files: []), fn(acc, entry) {
        let js_files = case string.ends_with(entry.file, ".js") {
          True -> [entry.file, ..acc.js_files]
          False -> acc.js_files
        }

        let css_files =
          entry.css
          |> list.filter(fn(file) { string.ends_with(file, ".css") })
          |> list.append(acc.css_files)

        ManifestAssets(js_files: js_files, css_files: css_files)
      })
    }
    Error(_) -> ManifestAssets(js_files: ["main.js"], css_files: ["main.css"])
  }
}

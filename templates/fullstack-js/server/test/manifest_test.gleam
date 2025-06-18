import gleam/list
import gleeunit
import manifest

pub fn main() {
  gleeunit.main()
}

pub fn parse_manifest_test() {
  let manifest_json =
    "{
    \"src/main.js\": {
      \"file\": \"main-RBwPTa1g.js\",
      \"name\": \"main\",
      \"src\": \"src/main.js\",
      \"isEntry\": true,
      \"css\": [
        \"main-aErs4z2H.css\"
      ]
    },
    \"src/other.js\": {
      \"file\": \"other-ABC123.js\",
      \"name\": \"other\",
      \"src\": \"src/other.js\",
      \"isEntry\": false,
      \"css\": []
    }
  }"

  let result = manifest.parse_manifest(manifest_json)

  assert result.js_files == ["main-RBwPTa1g.js"]
  assert result.css_files == ["main-aErs4z2H.css"]
}

pub fn parse_manifest_multiple_entries_test() {
  let manifest_json =
    "{
    \"src/main.js\": {
      \"file\": \"main-RBwPTa1g.js\",
      \"name\": \"main\",
      \"src\": \"src/main.js\",
      \"isEntry\": true,
      \"css\": [
        \"main-aErs4z2H.css\"
      ]
    },
    \"src/admin.js\": {
      \"file\": \"admin-XYZ789.js\",
      \"name\": \"admin\",
      \"src\": \"src/admin.js\",
      \"isEntry\": true,
      \"css\": [
        \"admin-DEF456.css\",
        \"shared-GHI789.css\"
      ]
    }
  }"

  let result = manifest.parse_manifest(manifest_json)

  // Note: order might vary due to dict processing
  assert list.contains(result.js_files, "main-RBwPTa1g.js")
  assert list.contains(result.js_files, "admin-XYZ789.js")
  assert list.contains(result.css_files, "main-aErs4z2H.css")
  assert list.contains(result.css_files, "admin-DEF456.css")
  assert list.contains(result.css_files, "shared-GHI789.css")
}

pub fn parse_manifest_invalid_json_test() {
  let result = manifest.parse_manifest("invalid json")

  assert result.js_files == ["main.js"]
  assert result.css_files == ["main.css"]
}

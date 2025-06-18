import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default {
  "fullstack-js": {
    name: "fullstack-js",
    templates: [path.join(__dirname, "templates", "fullstack-js")],
    output: ".",
    createSubFolder: false,
    data: {
      description: "Lustre fullstack app with JavaScript (client/server/shared)"
    },
    helpers: {
      lowerSnakeCase: (str) => str.toLowerCase().replace(/-/g, "_")
    }
  }
};
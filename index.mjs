#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import prompts from "prompts";
import * as kolorist from "kolorist";
import SimpleScaffold from "simple-scaffold";
const Scaffold = SimpleScaffold.default || SimpleScaffold;
const LogLevel = SimpleScaffold.LogLevel;
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/**
 * @param {fs.PathLike} path
 */
function isEmpty(path) {
  const files = fs.readdirSync(path);
  return files.length === 0 || (files.length === 1 && files[0] === ".git");
}

/**
 * @param {string} dir
 */
function emptyDir(dir) {
  if (!fs.existsSync(dir)) {
    return;
  }
  for (const file of fs.readdirSync(dir)) {
    if (file === ".git") {
      continue;
    }
    fs.rmSync(path.resolve(dir, file), { recursive: true, force: true });
  }
}

async function main() {
  let targetDir = "";

  let res;
  try {
    res = await prompts(
      [
        {
          type: "text",
          name: "projectName",
          message: kolorist.reset("Project name:"),
          validate: (value) =>
            value.trim() ? true : "Project name is required",
          onState(state) {
            targetDir = state.value || "";
          },
        },
        {
          type: () =>
            !fs.existsSync(targetDir) || isEmpty(targetDir) ? null : "confirm",
          name: "overwrite",
          message: () =>
            (targetDir === "."
              ? "Current directory"
              : `Target directory "${targetDir}"`) +
            ` is not empty. Remove existing files and continue?`,
        },
        {
          type: (_, { overwrite }) => {
            if (overwrite === false) {
              throw new Error(kolorist.red("✖") + " Operation cancelled");
            }
            return null;
          },
          name: "overwriteChecker",
        },
      ],
      {
        onCancel() {
          throw new Error(kolorist.red("✖") + " Operation cancelled");
        },
      },
    );
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }

  const root = path.join(process.cwd(), targetDir);

  /** @type { {projectName: string, overwrite: boolean} } */
  const { projectName, overwrite } = res;
  const name = projectName.toLowerCase().replaceAll("-", "_");

  if (overwrite) {
    emptyDir(root);
  } else if (!fs.existsSync(root)) {
    fs.mkdirSync(root, { recursive: true });
  }

  // Configure and run Simple Scaffold
  const config = {
    name: "fullstack-js",
    templates: [path.join(__dirname, "templates", "fullstack-js")],
    output: root,
    createSubFolder: false,
    data: {
      name: name,
      projectName: projectName,
    },
    helpers: {
      lowerSnakeCase: (str) => str.toLowerCase().replace(/-/g, "_"),
    },
  };

  try {
    // Try setting global log level
    if (SimpleScaffold.setLogLevel) {
      SimpleScaffold.setLogLevel(LogLevel.Warning);
    }

    await Scaffold({
      ...config,
      logLevel: LogLevel.Warning,
      quiet: true,
    });
  } catch (error) {
    console.error(kolorist.red("✖") + " Failed to scaffold project:", error.message);
    process.exit(1);
  }

  console.log(kolorist.bold(`Project scaffolded at ${root}`));
  console.log(
    `Run:
    cd ${targetDir}
    
    # Start development:
    cd client && npm install && npm run dev ${kolorist.gray("# in one terminal")}
    cd server && gleam run ${kolorist.gray("# in another terminal")}
    
    # Or build for production:
    cd client && npm install && npm run build
    cd server && gleam run
`,
  );
}

main();

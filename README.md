# create-gleam-lustre-fullstack

A scaffolding tool for creating full-stack Gleam applications with Lustre, featuring client-server hydration.

## Features

- 🚀 Full-stack Gleam/Lustre application setup
- 🔄 Client-server hydration out of the box
- 📦 Separate client, server, and shared modules
- ⚡ Vite for fast client-side development
- 🎯 TypeScript support for JavaScript interop
- 🧪 Test setup for all modules

## Usage

### Using npm create (recommended)

```bash
# From npm registry
npm create gleam-lustre-fullstack@latest

# From GitHub
npm create github:dvic/create-gleam-lustre-fullstack@latest
```

### Using npx

```bash
# From npm registry
npx create-gleam-lustre-fullstack@latest

# From GitHub
npx github:dvic/create-gleam-lustre-fullstack
```

### Using pnpm

```bash
pnpm create gleam-lustre-fullstack@latest
```

### Using yarn

```bash
yarn create gleam-lustre-fullstack
```

## What's Included

The scaffolded project includes:

- **Client**: Lustre frontend application with Vite
  - Hot module replacement
  - TypeScript declarations
  - CSS styling
  
- **Server**: Gleam backend server
  - Static file serving
  - API endpoints ready
  
- **Shared**: Common code between client and server
  - Shared types and logic
  - Reusable utilities

## Project Structure

```
your-project/
├── client/
│   ├── src/
│   │   ├── {name}_client.gleam
│   │   ├── main.js
│   │   └── main.css
│   ├── test/
│   ├── gleam.toml
│   ├── package.json
│   └── vite.config.js
├── server/
│   ├── src/
│   │   ├── {name}_server.gleam
│   │   └── manifest.gleam
│   ├── test/
│   ├── priv/
│   └── gleam.toml
└── shared/
    ├── src/
    │   └── shared.gleam
    ├── test/
    └── gleam.toml
```

## Getting Started

After scaffolding your project:

```bash
cd your-project

# Start development servers
# Terminal 1 - Start the client dev server
cd client && npm install && npm run dev

# Terminal 2 - Start the server
cd server && gleam run

# Or build for production
cd client && npm install && npm run build
cd server && gleam run
```

## Requirements

- [Gleam](https://gleam.run/) installed
- [Node.js](https://nodejs.org/) 16+ and npm
- [Erlang/OTP](https://www.erlang.org/) 23+ (for Gleam)

## Credits

Inspired by [create-gleam](https://github.com/Enderchief/create-gleam) by Enderchief.

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

If you find any bugs or have feature requests, please file an issue on the [GitHub repository](https://github.com/dvic/create-gleam-lustre-fullstack/issues).

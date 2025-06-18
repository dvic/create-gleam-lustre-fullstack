# {{lowerSnakeCase name}}

A demo fullstack Gleam/Lustre application with client-server hydration.

## Getting Started

### Development

1. Start the client build:
   ```bash
   cd client
   npm run dev
   ```

2. Start the server:
   ```bash
   cd server
   gleam run
   ```

### Production Build

1. Build the client:
   ```bash
   cd client
   npm run build
   ```

2. Start the server:
   ```bash
   cd server
   gleam run
   ```

## Project Structure

- `client/` - Frontend Lustre app (JavaScript target)
- `server/` - Backend Gleam app (Erlang target)
- `shared/` - Shared code between client and server
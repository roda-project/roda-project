# Project Code Generation Rules

## Core Stack
- **Web Framework**: Roda (STRICT: Do NOT use Rails, ActionController, or Sinatra conventions).
- **Autoloader**: Zeitwerk (Do NOT manually `require` files located in the `app/` directory. Only require standard libraries or gems).

## Code Style & Conventions

### 1. Routing (Roda)
- Do not create deep routing blocks. Use Roda's tree routing efficiently (`r.on`, `r.is`, `r.get`, `r.post`).

### 5. Boot Sequence & Initialization
- **`boot.rb`**: The absolute starting point. It sets up `Bundler` and boots `Zeitwerk`.
- **`config.ru`**: The Rack entrypoint. It defines middleware and mounts the primary Roda application class defined in `app.rb`.

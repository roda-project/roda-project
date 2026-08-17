# Project Code Generation Rules

## Core Stack
- **Web Framework**: Roda (STRICT: Do NOT use Rails, ActionController, or Sinatra conventions).
- **Autoloader**: Zeitwerk (Do NOT manually `require` files located in the `app/` directory. Only require standard libraries or gems).
- **No Rails Magic:** Do not use `ActiveSupport` methods (like `.present?` or `.blank?`) unless the gem is explicitly in the Gemfile.

## Code Style & Conventions

### 1. Types
- Rely on standard Ruby 3.x patterns. Use explicit YARD docs for method signatures.

### 2. Routing (Roda)
- Do not create deep routing blocks. Use Roda's tree routing efficiently (`r.on`, `r.is`, `r.get`, `r.post`).

### 3. Boot Sequence & Initialization
- **`boot.rb`**: The absolute starting point. It sets up `Bundler` and boots `Zeitwerk`.
- **`config.ru`**: The Rack entrypoint. It defines middleware and mounts the primary Roda application class defined in `app.rb`.

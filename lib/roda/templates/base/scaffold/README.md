# Rackr project scaffold

### Running

1. `$ bundle install`
2. `$ yarn`
3. `$ bin/dev`

for watch and compile assets:
1. `$ bin/dev-assets`

### Migrations

- `$ bin/db/migrate`

### Included

gems:
- `roda` for routes
- `sequel` + `sqlite3` for database work
- `rerun` for reload after changes
- `rspec` for tests
- `zeitwerk` for code load

js:
- `@hotwired/turbo`

assets:
- `esbuild` for bundle js assets

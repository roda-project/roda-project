# Roda Project

[![Gem Version](https://badge.fury.io/rb/roda-project.svg)](https://badge.fury.io/rb/roda-project)
[![CI](https://github.com/roda-project/roda-project/actions/workflows/main.yml/badge.svg)](https://github.com/roda-project/roda-project/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Roda Project is a command-line interface (CLI) tool that helps you quickly scaffold new [Roda](https://roda.jeremyevans.net/) web applications. It provides an interactive setup to generate a Roda project tailored to your specific needs, including choices for project type, database, authentication, and testing frameworks.

## Features

*   **Project Types**: Generate fullstack web applications (with frontend assets) or API-only backends.
*   **Database Support**: Integrate with SQLite, PostgreSQL, or MySQL, including basic connection configuration and migration setup.
*   **Authentication**: Optionally include [Rodauth](https://rodauth.jeremyevans.net/) for robust authentication features.
*   **Testing Frameworks**: Choose between [RSpec](https://rspec.info/) or [Minitest](https://minitest.github.io/) for your testing environment.
*   **Frontend Tooling**: For fullstack projects, includes basic frontend asset management with `esbuild`.

## Installation

Install the gem by adding it to your Gemfile:

```ruby
gem "roda-project"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install roda-project
```

## Usage

To create a new Roda project, simply run the `roda-project` command in your terminal:

```bash
roda-project
```

The CLI will then guide you through a series of interactive prompts to configure your new application:

1.  **Project name**: Enter the desired name for your project.
2.  **Project type**: Choose between `(1) Fullstack` (web application with frontend) or `(2) API` (backend only).
3.  **Test framework**: Select `(1) RSpec` or `(2) Minitest`.
4.  **Database? (Y/n)**: Decide if you want to include database support.
    *   If `Y`:
        *   **Database type**: Choose `(1) SQLite`, `(2) PostgreSQL`, or `(3) MySQL`.
        *   **Rodauth? (authentication) (Y/n)**: Decide if you want to include Rodauth for authentication.

After answering the prompts, `roda-project` will generate the project structure and files in a new directory with your specified project name.

### Example Workflow

```bash
$ roda-project
[roda-project vX.Y.Z]

Project name › my_roda_app
(1) Fullstack (2) API › 1
(1) RSpec (2) Minitest › 1
Database? (Y/n) › Y
(1) SQlite (2) PostgreSQL (3) MySQL › 2
Rodauth? (authentication) (Y/n) › Y

* creating base project
* adding front-end
* adding database
* adding rodauth
* adding test files

install dependences:

$ cd my_roda_app && bundle

* create your database

* put your dev database credentials in app/config/config.rb

migrate the database:

$ rake db:migrate

run and watch the project in dev mode:
$ rake dev:watch

compile and watch assets:
$ rake assets:watch

run 'rake' inside my_roda_app to see all available tasks
```

## After Project Generation

Once your project is generated, follow the on-screen instructions:

1.  Navigate into your new project directory:
    ```bash
    cd your_project_name
    ```
2.  Install dependencies:
    ```bash
    bundle install
    ```
3.  **If you chose a database other than SQLite**: Create your database manually and update your database credentials in `app/config/config.rb`.
4.  Migrate your database:
    ```bash
    rake db:migrate
    ```
5.  Start the development server and watch for changes:
    ```bash
    rake dev:watch
    ```
6.  **For fullstack projects**: Compile and watch frontend assets:
    ```bash
    rake assets:watch
    ```

You can explore all available Rake tasks by running `rake` inside your project directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/roda-project/roda-project](https://github.com/roda-project/roda-project). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/roda-project/roda-project/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Roda Project project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/roda-project/roda-project/blob/main/CODE_OF_CONDUCT.md).
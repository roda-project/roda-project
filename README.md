![](https://github.com/roda-project/roda-project/blob/main/lib/roda/templates/base/scaffold/public/images/roda-project.png)

[![Gem Version](https://badge.fury.io/rb/roda-project.svg)](https://badge.fury.io/rb/roda-project)
[![CI](https://github.com/roda-project/roda-project/actions/workflows/main.yml/badge.svg)](https://github.com/roda-project/roda-project/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Roda Project is a command-line interface (CLI) tool that helps you quickly scaffold new [Roda](https://roda.jeremyevans.net/) web applications. It provides an interactive setup to generate a Roda project tailored to your specific needs, including choices for project type, database, authentication, and testing frameworks.

[roda-project.github.io](https://roda-project.github.io/)

## Features

*   **Project Types**: Generate fullstack web applications (with frontend assets) or API-only backends.
*   **Database Support (Sequel)**: Integrate with SQLite, PostgreSQL, or MySQL, including basic connection configuration and migration setup.
*   **Authentication**: Optionally include [Rodauth](https://rodauth.jeremyevans.net/) for robust authentication features.
*   **Testing Frameworks**: Choose between [RSpec](https://rspec.info/) or [Minitest](https://minitest.github.io/) for your testing environment.
*   **Frontend Tooling**: For fullstack projects, includes basic frontend asset management with `esbuild`.

Included in all: **Live reload**, **Zeitwerk**, and a bunch of usefull **Rake tasks**

## Installation


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
2.  **Project type**: Choose between `(1) Fullstack` (web application with frontend), `(2) API` (backend only) or `(3) Minimal`.
3.  **Test framework**: Select `(1) RSpec` or `(2) Minitest`.
4.  **Database? (Y/n)**: Decide if you want to include database support.
    *   If `Y`:
        *   **Database type**: Choose `(1) SQLite`, `(2) PostgreSQL`, or `(3) MySQL`.
        *   **Rodauth? (authentication) (Y/n)**: Decide if you want to include Rodauth for authentication.

After answering the prompts, `roda-project` will generate the project structure and files in a new directory with your specified project name.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/roda-project/roda-project](https://github.com/roda-project/roda-project). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/roda-project/roda-project/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Roda Project project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/roda-project/roda-project/blob/main/CODE_OF_CONDUCT.md).

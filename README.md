# Highgroove-Generator

Generate Rails projects the way we like them.

## Dependencies

The capybara-webkit gem which the generator installs dependes on QT
being installed. On OSX with Hombrew run ```brew install qt``` to make
sure QT is installed.

## Installation

```bash
 gem install highgroove_generator

 # if you are using rbenv
 rbenv rehash
```

## Usage

```bash
 # create a new project
 highgroove new NAME

 # specify the database type
 highgroove new NAME --database=DATABASE

 # Don't create a heroku app
 highgroove new NAME --host=none

 # get help
 highgroove help
```

## What's included?
- [Rails](http://rubyonrails.org/) of course, currently the 3.2 branch
- [Postgres](http://www.postgresql.org/) all your database needs
- [Heroku](http://www.heroku.com/) for deployment ease, a Heroku app will automatically be created for you.
- [Slim](http://slim-lang.com/) for templating goodness

### The testing stack includes :
- [RSpec](https://github.com/rspec/rspec-rails/) for Behaviour-Driven Development
- [Factory Girl](https://github.com/thoughtbot/factory_girl), a fixtures replacement for generating test data
- [Forgery](https://github.com/sevenwire/forgery) for creating fake test data
- [Capybara-Webkit](https://github.com/thoughtbot/capybara-webkit) for integration testing with javascript
- [SimpleCov](https://github.com/colszowka/simplecov) for test coverage reporting

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

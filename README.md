# Highgroove-Generator

Generate Rails projects the way we like them.

## Dependencies

The capybara-webkit gem which the generator installs dependes on QT
being installed. On OSX with Hombrew run ```brew install qt``` to make
sure QT is installed.

## Installation

```bash
 gem install highgroove_generator
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

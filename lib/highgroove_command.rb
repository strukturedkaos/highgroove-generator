require "thor"

class HighgrooveCommand < Thor
  include Thor::Actions

  desc "new NAME", "Generates a new project with the given name"
  method_option :database, type: :string, default: 'postgresql', aliases: '-d'
  def new(name)
    run "rails new #{name} --skip-bundle -T -q -d #{options[:database]}"
    inside name do
      run "git init -q"
      gsub_file "Gemfile", /^ *#.*$/, ''
      gsub_file "Gemfile", /^ *$\n/, ''
      append_to_file "Gemfile" do
        <<-EOF
          group :test, :development do
            gem 'rspec-rails'
          end
          group :test do
            gem 'capybara'
            gem 'launchy'
            gem 'database_cleaner'
            gem 'capybara-webkit'
          end
        EOF
      end
      run "bundle install --quiet"
      run "rails g rspec:install"
      insert_into_file 'spec/spec_helper.rb', "\nrequire 'capybara/rspec'", after: "require 'rspec/autorun'"
      gsub_file 'spec/spec_helper.rb', / *# Remove this[^\n]*\n *config\.fixture_path[^\n]*\n\n/m, ''
      gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures = true/, 'config.use_transactional_fixture = false'
      insert_into_file 'spec/spec_helper.rb', after: "config.infer_base_class_for_anonymous_controllers = false\n" do
        <<-EOF

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
        EOF
      end
      append_to_file 'spec/spec_helper.rb', "\nCapybara.javascript_driver = :webkit\n"
    end
  end
end

require "thor"

class HighgrooveCommand < Thor
  include Thor::Actions

  desc "new NAME", "Generates a new project with the given name"
  method_option :database, type: :string, default: 'postgresql', aliases: '-d'
  method_option :host, type: :string, default: 'heroku', aliases: '-h',
    desc: 'Hosting to set up for this app. Values can be: heroku, none.'
  method_option :ruby, type: :string, default: 'rvm', aliases: '-r',
    desc: 'Ruby version manager to use. Values can be: rvm, none.'
  def new(name)
    @name = name
    run "rails new #{name} --skip-bundle -T -q -d #{options[:database]}"
    inside name do
      run "git init -q"
      gsub_file "Gemfile", /^ *#.*$/, ''
      gsub_file "Gemfile", /^ *$\n/, ''
      append_to_file "Gemfile" do
        <<-EOF
gem 'slim'
group :test, :development do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'forgery'
  gem 'heroku'
end
group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara-webkit'
  gem 'simplecov'
end
        EOF
      end
      if options[:ruby] == 'rvm'
        run "rvm 1.9.3-p125 do rvm --rvmrc --create 1.9.3-p125@#{name}"
      end
      rvm_run "gem install bundler"
      rvm_run "bundle install --quiet"
      rvm_run "rails g rspec:install"
      rvm_run "rails g forgery"
      insert_into_file 'spec/spec_helper.rb', "\nrequire 'capybara/rspec'", after: "require 'rspec/autorun'"
      gsub_file 'spec/spec_helper.rb', / *# Remove this[^\n]*\n *config\.fixture_path[^\n]*\n\n/m, ''
      gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures = true/, 'config.use_transactional_fixtures = false'
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
      prepend_to_file 'spec/spec_helper.rb' do
        <<-EOF
require 'simplecov'
SimpleCov.start

        EOF
      end
      append_to_file '.gitignore', "\ncoverage\n.rvmrc"
      remove_file 'public/index.html'
      remove_file 'README.rdoc'
      remove_file 'doc/README_FOR_APP'
      gsub_file 'config/database.yml', /username: .*$/, 'username:'
      rvm_run 'rake db:create'
    end

    copy_file "templates/README.md", "#{name}/README.md"
    copy_file "templates/home_controller.rb", "#{name}/app/controllers/home_controller.rb"
    copy_file "templates/index.slim", "#{name}/app/views/home/index.slim"
    remove_file "#{name}/config/routes.rb"
    copy_file "templates/routes.rb", "#{name}/config/routes.rb"

    inside name do
      rvm_run 'rake db:migrate'
      rvm_run 'git add .'
      rvm_run 'git commit -m "Initial Commit"'
      if options[:host] == 'heroku'
        rvm_run "heroku apps:create #{name.gsub(/[^a-z0-9\-]/, '')} -s cedar"
        rvm_run 'git push heroku master'
      end
    end
  end

  def self.source_root
    File.dirname(__FILE__)
  end

  private

  def rvm_run(command, config = {})
    if options[:ruby] == 'rvm'
      command = "rvm 1.9.3-p125@#{@name} do " + command
    end
    run command, config
  end
end

require "thor"
require "active_support/inflector"

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
gem 'slim-rails'
gem 'bootstrap-sass', '~> 2.0.4.0'
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

    # Layout file
    remove_file "#{name}/app/views/layouts/application.html.erb"
    copy_file   "templates/layout.html.slim", "#{name}/app/views/layouts/application.html.slim"

    # Remove css and js application files
    remove_file "#{name}/app/assets/javascripts/application.js"
    remove_file "#{name}/app/assets/stylesheets/application.css"
    copy_file   "templates/application.js.coffee", "#{name}/app/assets/javascripts/application.js.coffee"
    copy_file   "templates/application.css.scss",  "#{name}/app/assets/stylesheets/application.css.scss"

    copy_file "templates/README.md", "#{name}/README.md"
    copy_file "templates/home_controller.rb", "#{name}/app/controllers/home_controller.rb"
    copy_file "templates/index.slim", "#{name}/app/views/home/index.slim"
    remove_file "#{name}/config/routes.rb"
    template "templates/routes.rb.erb", "#{name}/config/routes.rb"

    inside name do
      rvm_run 'rake db:migrate'
      rvm_run 'git add .'
      rvm_run 'git commit -m "Initial Commit"'
      if options[:host] == 'heroku'
        rvm_run "heroku apps:create #{heroku_name(name)} -s cedar"
        rvm_run 'git push heroku master'
      end
    end
  end


  desc "destroy NAME", "Destroys an app that was generated by the new action"
  def destroy(name)
    rvm_run "heroku apps:destroy #{heroku_name(name)} --confirm #{heroku_name(name)}"
    remove_dir name
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

  def heroku_name(name)
    name.gsub(/[^a-z0-9\-]/, '')
  end
end

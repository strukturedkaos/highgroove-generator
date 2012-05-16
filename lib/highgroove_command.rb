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
      run "bundle install --quiet"
    end
  end
end

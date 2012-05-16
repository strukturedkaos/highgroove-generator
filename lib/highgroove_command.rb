require "thor"

class HighgrooveCommand < Thor
  include Thor::Actions

  desc "new NAME", "Generates a new project with the given name"
  def new(name)
    run "rails new #{name}"
  end
end

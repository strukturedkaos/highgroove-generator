require "thor"

class HighgrooveCommand < Thor
  include Thor::Actions

  default_task :generate_project

  desc "generate_project", "Generates a new project"
  def generate_project
    run 'rails new test_application'
  end
end

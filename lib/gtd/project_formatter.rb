require "rainbow"
require "rainbow/ext/string"
require_relative "compact_project_formatter"

module Gtd
  class ProjectFormatter < CompactProjectFormatter
    def format(project)
      summary = super(project)
      tasks = if project.todo_txt.tasks.empty?
                "\n        No next actions - time to archive?".color(:red).bold
              else
                "\n      " + "Tasks".color(:yellow).underline + "\n" + project.todo_txt.tasks.map { |task|
                  "      * ".color(:cyan) + task.description.color(:white)
                }.join("\n")
              end
      summary + tasks + "\n\n"
    end
  end
end

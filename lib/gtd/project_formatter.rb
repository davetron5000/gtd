require "rainbow"
require "rainbow/ext/string"
module Gtd
  class ProjectFormatter
    def format(project)
      summary = sprintf("[%s] %s\n",project.id.to_s.color(:white),project.name.color(:green))
      tasks = if project.todo_txt.tasks.empty?
                "\n  No next actions - time to archive?".color(:red)
              else
                "\n  Tasks".color(:yellow) + "\n" + project.todo_txt.tasks.map { |task|
                  "    *".color(:cyan) + task.description.color(:white)
                }.join("\n")
              end
      summary + tasks + "\n\n"
    end
  end
end

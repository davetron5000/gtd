require "rainbow"
require "rainbow/ext/string"
module Gtd
  class ProjectFormatter
    def format(project)
      id_padding = 3
      if Rainbow.enabled
        id_padding *= 4
      end
      summary = sprintf("[%#{id_padding}s] %s +%s\n",project.id.to_s.color(:white),project.name.color(:green),project.code.color(:yellow))
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

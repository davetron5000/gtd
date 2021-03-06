require "rainbow"
require "rainbow/ext/string"
module Gtd
  class TaskFormatter
    def format(task)
      id_padding = 3
      if Rainbow.enabled
        id_padding *= 4
      end

      completed     = task.completed? ? " (completed: #{task.completed_on.to_s})".color(:green) : ""
      contexts      = task.contexts.empty? ? "" : "  " + task.contexts.map {|_| "@#{_}" }.sort.join(" ").color(:cyan)
      project_codes = task.project_codes.empty? ? "" : "  " + task.project_codes.map {|_| "+#{_}" }.sort.join(" ").color(:green)

      sprintf("[%#{id_padding}s] %s%s%s%s\n",task.id.to_s.color(:yellow),
                                             task.description.strip.to_s.color(:white),
                                             contexts,
                                             project_codes,
                                             completed)
    end
  end
end

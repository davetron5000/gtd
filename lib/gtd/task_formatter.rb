require "rainbow"
require "rainbow/ext/string"
module Gtd
  class TaskFormatter
    def format(task)
      completed = task.completed? ? " (completed: #{task.completed_on.to_s})".color(:green) : ""
      contexts = task.contexts.empty? ? "" : "  " + task.contexts.map {|_| "@#{_}" }.sort.join(" ").color(:cyan)
      sprintf("[%s] %s%s%s\n",task.id.to_s.color(:white),
                              task.description.strip.to_s.color(:yellow),
                              contexts,
                              completed)
    end
  end
end

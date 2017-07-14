require "rainbow"
require "rainbow/ext/string"
module Gtd
  class ProjectFormatter
    def format(project)
      sprintf("[%s] %s\n",project.id.to_s.color(:white),project.name.color(:green))
    end
  end
end

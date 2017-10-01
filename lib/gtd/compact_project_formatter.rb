require "rainbow"
require "rainbow/ext/string"
module Gtd
  class CompactProjectFormatter
    def format(project)
      id_padding = 3
      if Rainbow.enabled
        id_padding *= 4
      end
      context = project.default_context.nil? ? "" : " @#{project.default_context}"
      sprintf("[%#{id_padding}s] %s +%s%s\n",project.id.to_s.color(:white),
                                           project.name.color(:green),
                                           project.code.color(:yellow),
                                           context.color(:cyan))
    end
  end
end

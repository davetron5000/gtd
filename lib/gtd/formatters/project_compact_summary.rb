module Gtd
  module Formatters
  end
end

class Gtd::Formatters::ProjectCompactSummary
  def initialize(project)
    @project = project
  end

  def to_s
    formatted_id = if @project.id < 10
                     " #{@project.id}"
                     else
                       @project.id.to_s
                     end
    Rainbow("[#{formatted_id}]: ").faint + Rainbow(@project.name).bright
  end
end

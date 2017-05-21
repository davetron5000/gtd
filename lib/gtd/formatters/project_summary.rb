module Gtd
  module Formatters
  end
end
require_relative "project_compact_summary"

class Gtd::Formatters::ProjectSummary < Gtd::Formatters::ProjectCompactSummary
  def initialize(project)
    @project = project
  end

  def to_s
    next_action = if @project.next_action.nil?
                    Rainbow("⛔️  No Next Action").red
                  else
                    Rainbow("👉  #{@project.next_action.task}").green
                  end
    super + "\n      " + next_action
  end
end

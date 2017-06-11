module Gtd
  module Formatters
  end
end

class Gtd::Formatters::Task
  def initialize(task, show_id: true)
    @task    = task
    @show_id = show_id
  end

  def to_s
    id_string = if @show_id
                  Rainbow("[#{@task.id}]: ").faint
                else
                  ""
                end
    id_string + @task.task + " " + Rainbow(@task.contexts.map { |_| "@#{_}" }.join(" ")).yellow + " " + Rainbow(@task.projects.map {|_| "+#{_}" }.join(" ")).cyan + Rainbow("#{@task.completed? ? ' (Completed)' : ''}").green.italic
  end
end

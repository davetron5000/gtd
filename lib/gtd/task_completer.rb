require "rainbow"

module Gtd
  class TaskCompleter
    def initialize(todo_list,projects)
      @todo_list = todo_list
      @projects  = projects
    end

    class NoSuchProject
      def initialize(project_code)
        @project_code = project_code
      end

      def to_s
        "'#{project_code}' isn't a tracked project, no next action"
      end
    end

    class NextTaskAddedToTodoList
      def initialize(next_action)
        @next_action = next_action
      end

      def to_s
        "Next action is #{Rainbow(@next_action.task).bright}"
      end
    end

    class TaskNotPartOfAProject
    end

    def complete_task(task_id)
      task = @todo_list.complete_task(task_id)
      project_code = task.projects.first
      if project_code
        project = @projects.find_by_code(project_code)
        if project.nil?
          return NoSuchProject.new(project_code)
        end
        next_action = project.next_action
        @todo_list.add_task(next_action)
        @todo_list.save!
        NextTaskAddedToTodoList.new(next_action)
      else
        TaskNotPartOfAProject.new
      end
    end
  end
end
